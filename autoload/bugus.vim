if has('ruby') "Bugus will not work without Ruby support
	ruby load File.join(VIM::evaluate("expand('<sfile>:p:h')"),'bugus.rb')
endif
