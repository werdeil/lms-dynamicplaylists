-- PlaylistName:PLUGIN_DYNAMICPLAYLISTS3_BUILTIN_PLAYLIST_CONTEXT_GENRE_SONGS_LEASTPLAYED
-- PlaylistGroups:Context menu lists/ genre
-- PlaylistMenuListType:contextmenu
-- PlaylistCategory:genres
-- PlaylistAPCdupe:yes
-- PlaylistParameter1:genre:PLUGIN_DYNAMICPLAYLISTS3_PARAMNAME_SELECTGENRE:
select mostplayed.url from
	(select distinct tracks.url from tracks
		join genre_track on
			genre_track.track = tracks.id and genre_track.genre='PlaylistParameter1'
		join tracks_persistent on
			tracks_persistent.urlmd5 = tracks.urlmd5
		left join library_track on
			library_track.track = tracks.id
		left join dynamicplaylist_history on
			dynamicplaylist_history.id=tracks.id and dynamicplaylist_history.client='PlaylistPlayer'
		where
			tracks.audio = 1
			and tracks.secs >= 'PlaylistTrackMinDuration'
			and dynamicplaylist_history.id is null
		and
			case
				when ('PlaylistCurrentVirtualLibraryForClient'!='' and 'PlaylistCurrentVirtualLibraryForClient' is not null)
				then library_track.library = 'PlaylistCurrentVirtualLibraryForClient'
				else 1
			end
		group by tracks.id
		order by tracks_persistent.playCount asc, random()
		limit 'PlaylistLimit') as mostplayed
	order by random();
