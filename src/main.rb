require 'downloader'

sites = {'動物まとめ2ちゃんねる' => 'http://www.dobutu2ch.net/index.rdf'
		}

threads = []

sites.each{ |k,v|
	threads << Thread.start{
		begin
			Nameka::Downloader.new(k,v).dl
		rescue => exc
			puts exc.to_s + ":" + k
		end
	}
}

threads.each{ |t|
	t.join
}


