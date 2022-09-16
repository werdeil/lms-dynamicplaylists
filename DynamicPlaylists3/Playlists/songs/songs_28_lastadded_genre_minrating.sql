-- PlaylistName:PLUGIN_DYNAMICPLAYLISTS3_BUILTIN_PLAYLIST_SONGS_LASTADDED_GENRE_MINRATING
-- PlaylistGroups:Songs
-- PlaylistCategory:songs
-- PlaylistParameter1:list:PLUGIN_DYNAMICPLAYLISTS3_PARAMNAME_SELECTLASTADDEDPERIOD_SONGS:604800:PLUGIN_DYNAMICPLAYLISTS3_PARAMVALUENAME_SELECTLASTADDEDPERIOD_1WEEK,1209600:PLUGIN_DYNAMICPLAYLISTS3_PARAMVALUENAME_SELECTLASTADDEDPERIOD_2WEEKS,2419200:PLUGIN_DYNAMICPLAYLISTS3_PARAMVALUENAME_SELECTLASTADDEDPERIOD_4WEEKS,7257600:PLUGIN_DYNAMICPLAYLISTS3_PARAMVALUENAME_SELECTLASTADDEDPERIOD_3MONTHS,14515200:PLUGIN_DYNAMICPLAYLISTS3_PARAMVALUENAME_SELECTLASTADDEDPERIOD_6MONTHS,29030399:PLUGIN_DYNAMICPLAYLISTS3_PARAMVALUENAME_SELECTLASTADDEDPERIOD_12MONTHS
-- PlaylistParameter2:multiplegenres:PLUGIN_DYNAMICPLAYLISTS3_PARAMNAME_SELECTGENRES:
-- PlaylistParameter3:list:PLUGIN_DYNAMICPLAYLISTS3_PARAMNAME_SELECTMINRATING:0:PLUGIN_DYNAMICPLAYLISTS3_PARAMVALUENAME_UNRATED,20:*,40:**,60:***,80:****,100:*****
-- PlaylistParameter4:list:PLUGIN_DYNAMICPLAYLISTS3_PARAMNAME_INCLUDESONGS:0:PLUGIN_DYNAMICPLAYLISTS3_PARAMVALUENAME_SONGS_ALL,1:PLUGIN_DYNAMICPLAYLISTS3_PARAMVALUENAME_SONGS_UNPLAYED,2:PLUGIN_DYNAMICPLAYLISTS3_PARAMVALUENAME_SONGS_PLAYED

select distinct tracks.url from tracks
	join genre_track on
		genre_track.track = tracks.id and genre_track.genre in ('PlaylistParameter2')
	left join library_track on
		library_track.track = tracks.id
	join tracks_persistent on
		tracks_persistent.urlmd5 = tracks.urlmd5 and ifnull(tracks_persistent.rating, 0) >= 'PlaylistParameter3'
	left join dynamicplaylist_history on
		dynamicplaylist_history.id=tracks.id and dynamicplaylist_history.client='PlaylistPlayer'
	where
		tracks.audio = 1
		and tracks.secs >= 'PlaylistTrackMinDuration'
		and dynamicplaylist_history.id is null
		and tracks_persistent.added >= ((select max(ifnull(tracks_persistent.added,0)) from tracks_persistent) - 'PlaylistParameter1')
		and
			case
				when ('PlaylistCurrentVirtualLibraryForClient' != '' and 'PlaylistCurrentVirtualLibraryForClient' is not null)
				then library_track.library = 'PlaylistCurrentVirtualLibraryForClient'
				else 1
			end
		and
			case
				when 'PlaylistParameter4'=1 then ifnull(tracks_persistent.playCount, 0) = 0
				when 'PlaylistParameter4'=2 then ifnull(tracks_persistent.playCount, 0) > 0
				else 1
			end
		and not exists (select * from tracks t2, genre_track, genres
						where
							t2.id = tracks.id and
							tracks.id = genre_track.track and
							genre_track.genre = genres.id and
							genres.name in ('PlaylistExcludedGenres'))
	order by random()
	limit 'PlaylistLimit';
