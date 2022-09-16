-- PlaylistName:PLUGIN_DYNAMICPLAYLISTS3_BUILTIN_PLAYLIST_CONTEXT_YEAR_SONGS_NEVERPLAYED
-- PlaylistGroups:Context menu lists/ year
-- PlaylistMenuListType:contextmenu
-- PlaylistCategory:years
-- PlaylistAPCdupe:yes
-- PlaylistParameter1:year:PLUGIN_DYNAMICPLAYLISTS3_PARAMNAME_SELECTYEAR:
select distinct tracks.url from tracks
	left join library_track on
		library_track.track = tracks.id
	join tracks_persistent on
		tracks_persistent.urlmd5 = tracks.urlmd5 and ifnull(tracks_persistent.playCount, 0) = 0
	left join dynamicplaylist_history on
		dynamicplaylist_history.id=tracks.id and dynamicplaylist_history.client='PlaylistPlayer'
	where
		tracks.audio = 1
		and tracks.year='PlaylistParameter1'
		and tracks.secs >= 'PlaylistTrackMinDuration'
		and dynamicplaylist_history.id is null
		and
			case
				when ('PlaylistCurrentVirtualLibraryForClient'!='' and 'PlaylistCurrentVirtualLibraryForClient' is not null)
				then library_track.library = 'PlaylistCurrentVirtualLibraryForClient'
				else 1
			end
		and not exists (select * from tracks t2,genre_track,genres
						where
							t2.id=tracks.id and
							tracks.id=genre_track.track and 
							genre_track.genre=genres.id and
								genres.name in ('PlaylistExcludedGenres'))
	group by tracks.id
	order by random()
	limit 'PlaylistLimit';
