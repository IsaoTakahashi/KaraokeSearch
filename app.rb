require 'sinatra/base'
require 'sinatra/reloader'
require 'haml'
require 'sass'
require 'active_record'
require 'activerecord-import'
require 'json'

require_relative 'config/environment'
require_relative 'models/init'
require_relative 'lib/init'

environment = ENV['RACK_ENV'].to_sym
ActiveRecord::Base.configurations = YAML.load(ERB.new(File.read('config/database.yml')).result)
ActiveRecord::Base.establish_connection(environment)

class Server < Sinatra::Base
    get '/' do
        @record_count = KaraokeSong.count
        @karaoke_songs = KaraokeSong.order('created_at desc').limit(10)
        haml :index
    end

    get '/search' do
        limit_num = 2500
        result_songs = []
        artist = SearchStringUtil.create_search_string(params['artist'])
        title = SearchStringUtil.create_search_string(params['title'])

        if artist.blank? && title.blank? then
            status 400
            return
        elsif title.blank? then
            result_songs = KaraokeSong.where('artist_name_search LIKE ?','%'+artist+'%').order('artist_name_search ASC, song_title_search ASC, created_at DESC').limit(limit_num)
        elsif artist.blank?
            result_songs = KaraokeSong.where('song_title_search LIKE ?','%'+title+'%').order('artist_name_search ASC, song_title_search ASC, created_at DESC').limit(limit_num)
        else
            result_songs = KaraokeSong.where('artist_name_search LIKE ?','%'+artist+'%').where('song_title_search LIKE ?','%'+title+'%').order('artist_name_search ASC, song_title_search ASC, created_at DESC').limit(limit_num)
        end

        # if result_songs.blank? then
        # 	status 404
        # 	return
        # end

        result_songs.to_json(:root => false)
    end

    get '/karaokes.json' do
        content_type :json, :charset => 'utf-8'

        hits = (params['hits'] || 10).to_i
        page = (params['page'] || 1).to_i
        order = (params['order'] || "desc").upcase

        unless order == "ASC" || order == "DESC" then
            status 400
            return 'invalid parameter'
        end

        start_idx = hits * (page.to_i-1)

        karaoke_songs = KaraokeSong.order("id " + order).limit(hits).offset(start_idx)
        karaoke_songs.to_json(:root => false)
    end

    get '/karaoke/:id' do |id|
        karaoke_song = KaraokeSong.find_by_id(id)
        unless karaoke_song then
            status 404
            return
        end

        karaoke_song.to_json(:root => false)
    end

    post '/karaoke', provides: :json  do
        body = request.body.read

        begin
            req_data = JSON.parse(body.to_s)
        rescue Exception => e
            p e
            status 400
            return
        end

        requested_songs = []
        #p req_data
        req_data.each do |reqData|
            karaoke = KaraokeSong.new
            karaoke.song_id = reqData['song_id']
            karaoke.artist_id = reqData['artist_id']
            karaoke.song_title = reqData['song_title']
            karaoke.artist_name = reqData['artist_name']

            karaoke.song_title_search = reqData['song_title']
            karaoke.artist_name_search = reqData['artist_name']

            karaoke_song =  KaraokeSong.find_by_song_id(karaoke.song_id)
            if karaoke_song then
                next
                #status 409
                #return
            end

            requested_songs << karaoke
        end

        KaraokeSong.import requested_songs
        # requested_songs.each do |karaoke|
        # 	karaoke.save
        # end

        status 202
        requested_songs.to_json
    end

    get '/karaoke/search/refresh' do

        begin
            columns = [:id, :song_title_search, :artist_name_search]
            KaraokeSong.all.find_in_batches(:batch_size => 1000) do |songs|
                songs.each do |song|
                    song.song_title_search = SearchStringUtil.create_search_string(song.song_title)
                    song.artist_name_search = SearchStringUtil.create_search_string(song.artist_name)
                end
                values = songs.map {|song| [song.id, song.song_title_search, song.artist_name_search]}
                KaraokeSong.import columns, values, :on_duplicate_key_update => [:song_title_search,:artist_name_search], :validate => false
            end
        rescue Exception => e
            p e
            status 500
            return
        end

        status 202
        "success"
    end

    delete '/karaoke/:id' do |id|
        karaoke_song = KaraokeSong.find_by_id(id)
        unless karaoke_song then
            status 404
            return
        end

        karaoke_song.delete
        status 204
    end
end
