
module BugusUtil
    require 'net/http'
    require 'rexml/document'
    require 'rexml/xmldecl'
    def self.soap_request(url,method,data={})
        req_doc=REXML::Document.new

        req_doc.add REXML::XMLDecl.new('1.0','UTF-8')

        envelope=REXML::Element.new('env:Envelope')
        envelope.add_attribute 'xmlns:tns',"http://futureware.biz/mantisconnect"
        envelope.add_attribute 'xmlns:env',"http://schemas.xmlsoap.org/soap/envelope/"

        body=REXML::Element.new('env:Body')

        methodElement=REXML::Element.new(method.to_s)

        data.each do|k,v|
            argument=REXML::Element.new(k.to_s)
            argument.text=v.to_s
            methodElement.elements<<argument
        end

        body.elements<<methodElement
        envelope.elements<<body

        req_doc.elements<<envelope

        uri=URI(url)
        rsp=Net::HTTP::new(uri.host).post(uri.path,req_doc.to_s,'Content-Type'=>'text/xml')

        rsp_doc=nil

        if rsp.body.bytes.take(3)==[0x1f,0x8B,0x08]
            require 'zlib'
            gz=Zlib::GzipReader.new(StringIO.new(rsp.body))
            rsp_doc=REXML::Document.new(gz.read)
            gz.close
        else
            rsp_doc=REXML::Document.new(rsp.body)
        end

        return_element=rsp_doc.get_elements('//return').first

        if return_element.nil?
            raise rsp_doc.get_elements('//faultstring').first.text
        end

        return parse_xml_element(return_element)
    end

    def self.parse_xml_element(element)
        if element.nil?
            return nil
        end
        unless element.has_elements?
            return element.text
        end
        unless element.attribute('arrayType').nil?
            return element.elements.map{|e|parse_xml_element(e)}
        end
        return Hash[element.elements.map{|e|[e.name,parse_xml_element(e)]}]
    end
end
