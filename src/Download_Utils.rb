require 'uri'
require 'rss'
require 'kconv'
require 'open-uri'
require 'date'
require 'fileutils'

module Nameka


class Download_Utils
	LOG_FILE = "log_v2.dat"		#エラー等のログを保存するファイル名
	SUBJECTS_FILE = "subjects.dat" #今まで保存した記事のタイトル一覧
	EXTENSIONS = ['.jpg','.jpeg','jpe','jfif','bid','.png','.bmp','.gif']
	

	#RSS中で初めて見る記事のタイトルを配列にする
	def self.get_new_subjects(url_rss)
		#このメソッドを実行する前にバックアップをとる
		FileUtils.cp(SUBJECTS_FILE,SUBJECTS_FILE+"_old.txt")

		new_subjects = []		#新しいタイトル一覧
		known_subjects = []		#既にダウンロードしたタイトル一覧
		open(SUBJECTS_FILE,'r')do |file|
			known_subjects = file.readlines
		end
		# 文頭文末の空白文字(特に改行）の除去
		known_subjects.each do |title|
			title.strip!
		end

		parsed = RSS::Parser.parse(url_rss)
		parsed.items.each do |v|
			title 	= Kconv.tosjis v.title.gsub(/\s|　/,'_').strip
			page_url = v.link
			#もし既にDL済みで無ければnew_subjectsに登録
			if known_subjects.index(title) == nil
				new_subjects << [title,page_url]
				open(SUBJECTS_FILE,'a') do |file|
					file.puts title
				end
			end
		end 
	
		return new_subjects
	end

	#記事名の配列を正規表現にかけて抽出
	def self.regexp_subjects(pattern,subjects_hash)
		new_subjects = []
		subjects_hash.each{ |title,page_url|
			if(pattern =~ title) 
				new_subjects << [title,page_url]
			end
		}
		return new_subjects
	end

	#ページ内の画像リンクを探して配列にして返す
	def self.get_photo_links(url)
		photo_links = []
		page = ''
		open(url){ |data|
			page = data.read.gsub(/\s/,'')	# 空白を削除しないとどうしても画像リンクが引っかからない
		}

		while /(<a).*?(a>)/ =~ page
			#リンクを探す
			page = $'
			str = $&
			link_adrs = ''
			#そのリンク先が画像かどうか
			if /(href=")(.*?)(")/ =~ str
				link_adrs = $2
				if EXTENSIONS.index(File::extname(link_adrs) ) != nil
					#相対パスの場合は絶対パスに変換
					if(/^\./ =~ link_adrs)
						old_link_adrs = link_adrs
						link_adrs = URI.join(url,link_adrs).to_s
						#ちゃんと動作するか分からないのでログに書き込んでおこう
						open(LOG_FILE,'a'){ |file|
							file.write(Kconv('相対パスを絶対パスに変換 ' + url + "\n"))
							file.write(old_link_adrs + ' => ' + link_adrs + "\n")
						}
					end
					#リンク先が画像だったので配列に追加
					photo_links << link_adrs
				end
			end
		end
		
		return photo_links
	end

	#指定されたアドレスの画像を保存
	def	self.download_photo(url,dir_name)
		url = Kconv.tosjis url
		file_name = File::basename( url )
		file_path = dir_name + '/' + file_name
		
		#もしディレクトリが無ければ作成
		FileUtils.mkdir_p(dir_name)

		open(file_path,'wb'){ |file|
			begin
				open(url){ |data|
					file.write(data.read)
				}
			rescue => exc
				open(LOG_FILE,'a'){ |f|
					f.write Kconv.tosjis "例外:"+exc+":"+file_path+"\n"+url+'\n'
					print Kconv.tosjis "例外:"+exc+":"+url+"\n"
				}
			end
		}	
	end

end


end#end of module