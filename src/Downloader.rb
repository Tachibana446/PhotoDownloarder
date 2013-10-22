require 'download_utils'

module Nameka

class Downloader
	def initialize (site_name , site_rss_url)
		@site_name 	= Kconv.tosjis site_name
		@rss_url 	= site_rss_url
		
	end

	def dl
		puts (@site_name + Kconv.tosjis(" ダウンロード開始 ") ) 
		#新しい記事の配列を取得
		Download_Utils::get_new_subjects(@rss_url).each{ |title,link|
			puts Kconv.tosjis title 
			dir_name = @site_name + "/" + title 
			#画像の配列を取得
			Download_Utils::get_photo_links(link).each{ |picture_url|
				#アドレスの画像を保存
				Download_Utils::download_photo(picture_url,dir_name)
			}
		}
		puts ( @site_name.to_s + Kconv.tosjis(" ダウンロード完了 ") )
	end

	def dl_regexp(pattern)
		puts (@site_name + Kconv.tosjis(" ダウンロード開始") )
		#新しい記事の配列を取得
		subjects = Download_Utils::get_new_subjects(@rss_url)
		subjects = Download_Utils::regexp_subjects(pattern,subjects)
		subjects.each{ |title,link|
			puts Kconv.tosjis title
			dir_name = @site_name + "/" + title
			#画像の配列を取得
			Download_Utils::get_photo_links(link).each{ |picture_url|
				#アドレスの画像を保存
				Download_Utils::download_photo(picture_url,dir_name)
			}
		}
		puts ( @site_name.to_s + Kconv.tosjis("ダウンロード完了") )
	end
end

end