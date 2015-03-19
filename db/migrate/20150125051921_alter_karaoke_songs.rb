class AlterKaraokeSongs < ActiveRecord::Migration
    def change
        add_column :karaoke_songs, :song_title_search, :string

        add_column :karaoke_songs, :artist_name_search, :string
    end
end
