load File.join(File.expand_path(File.dirname(__FILE__)),'bugus.rb')
load File.join(File.expand_path(File.dirname(__FILE__)),'bugus_util.rb')
module Bugus
	class MantisClient
		def initialize(url,args={})
			@args=args
			if args[:dont_use_default_path]
				@url=url
			else
				@url="#{url}/api/soap/mantisconnect.php?wsdl"
			end
		end

		def call(method,args={})
			return BugusUtil::soap_request(@url,method,{
				:username=>@args[:username],:password=>@args[:password]
			}.merge(args))#.body
		end

		def fetch_projects
			call(:mc_projects_get_user_accessible).map do|elem|
				project=Bugus::Project.new(elem['name'],elem['description'])
				project
			end
		end
	end
end
