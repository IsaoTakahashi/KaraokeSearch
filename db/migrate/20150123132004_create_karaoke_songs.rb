class CreateKaraokeSongs < ActiveRecord::Migration
    def change
        create_table :karaoke_songs do |t|
            t.string :song_id
            t.string :artist_id
            t.string :song_title
            t.string :artist_name
            t.timestamps
        end
    end
end
