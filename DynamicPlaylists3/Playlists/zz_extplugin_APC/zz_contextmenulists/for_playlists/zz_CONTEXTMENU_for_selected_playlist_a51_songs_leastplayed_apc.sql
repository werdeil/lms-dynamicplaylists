-- PlaylistName:PLUGIN_DYNAMICPLAYLISTS3_BUILTIN_PLAYLIST_CONTEXT_PLAYLIST_SONGS_LEASTPLAYED_APC
-- PlaylistGroups:Context menu lists/ playlist
-- PlaylistMenuListType:contextmenu
-- PlaylistCategory:playlists
-- PlaylistParameter1:playlist:PLUGIN_DYNAMICPLAYLISTS3_PARAMNAME_SELECTPLAYLIST:
select leastplayed.url from
	(select distinct playlist_track.track as url from playlist_track
	join tracks on
		tracks.url = playlist_track.track
	left join library_track on
		library_track.track = tracks.id
	join alternativeplaycount on
		alternativeplaycount.urlmd5 = tracks.urlmd5
	left join dynamicplaylist_history on
		dynamicplaylist_history.id=tracks.id and dynamicplaylist_history.client='PlaylistPlayer'
	where
		playlist_track.playlist='PlaylistParameter1'
		and tracks.audio = 1
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
	group by playlist_track.track
	order by alternativeplaycount.playCount asc,random()
	limit 'PlaylistLimit') as leastplayed
	order by random();
