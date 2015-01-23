require 'sinatra/base'
require 'sinatra/reloader'
require 'haml'
require 'sass'
require 'coffee-script'
require 'active_record'
require 'json'

require_relative 'models/init'

ActiveRecord::Base.configurations = YAML.load(ERB.new(File.read('config/database.yml')).result)
ActiveRecord::Base.establish_connection(ENV['RACK_ENV'])

class Server < Sinatra::Base
    get '/' do
        haml :index
    end

    get '/karaokes.json' do
        content_type :json, :charset => 'utf-8'
        karaoke_songs = KaraokeSong.order("created_at DESC").limit(10)
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

    post '/karaoke' do
        body = request.body.read
        status 400 if body == ''

        reqData = JSON.parse(body.to_s)

        karaoke = KaraokeSong.new
        karaoke.song_id = reqData['song_id']
        karaoke.artist_id = reqData['artist_id']
        karaoke.song_title = reqData['song_title']
        karaoke.artist_name = reqData['artist_name']
        karaoke.save

        status 202
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
