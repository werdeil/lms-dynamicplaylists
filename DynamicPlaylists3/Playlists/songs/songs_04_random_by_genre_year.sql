-- PlaylistName:PLUGIN_DYNAMICPLAYLISTS3_BUILTIN_PLAYLIST_SONGS_RANDOM_GENRE_YEARS
-- PlaylistGroups:Songs
-- PlaylistCategory:songs
-- PlaylistParameter1:multiplegenres:PLUGIN_DYNAMICPLAYLISTS3_PARAMNAME_SELECTGENRES:
-- PlaylistParameter2:multipleyears:PLUGIN_DYNAMICPLAYLISTS3_PARAMNAME_SELECTYEARS:
-- PlaylistParameter3:list:PLUGIN_DYNAMICPLAYLISTS3_PARAMNAME_INCLUDESONGS:0:PLUGIN_DYNAMICPLAYLISTS3_PARAMVALUENAME_SONGS_ALL,1:PLUGIN_DYNAMICPLAYLISTS3_PARAMVALUENAME_SONGS_UNPLAYED,2:PLUGIN_DYNAMICPLAYLISTS3_PARAMVALUENAME_SONGS_PLAYED
select distinct tracks.url from tracks
	join genre_track on
		genre_track.track = tracks.id and genre_track.genre in ('PlaylistParameter1')
	left join library_track on
		library_track.track = tracks.id
	join tracks_persistent on
		tracks_persistent.urlmd5 = tracks.urlmd5
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
		and ifnull(tracks.year, 0) in ('PlaylistParameter2')
		and
			case
				when 'PlaylistParameter3'=1 then ifnull(tracks_persistent.playCount, 0) = 0
				when 'PlaylistParameter3'=2 then ifnull(tracks_persistent.playCount, 0) > 0
				else 1
			end
	order by random()
	limit 'PlaylistLimit';
