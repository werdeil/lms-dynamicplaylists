-- PlaylistName:PLUGIN_DYNAMICPLAYLISTS4_BUILTIN_PLAYLIST_CONTEXT_YEAR_ALBUMS_TOPRATEDAVG
-- PlaylistGroups:Context menu lists/ year
-- PlaylistMenuListType:contextmenu
-- PlaylistCategory:years
-- PlaylistTrackOrder:ordered
-- PlaylistLimitOption:unlimited
-- PlaylistParameter1:year:PLUGIN_DYNAMICPLAYLISTS4_PARAMNAME_SELECTYEAR:
-- PlaylistParameter2:list:PLUGIN_DYNAMICPLAYLISTS4_PARAMNAME_INCLUDESONGS:0:PLUGIN_DYNAMICPLAYLISTS4_PARAMVALUENAME_SONGS_ALL,1:PLUGIN_DYNAMICPLAYLISTS4_PARAMVALUENAME_SONGS_UNPLAYED,2:PLUGIN_DYNAMICPLAYLISTS4_PARAMVALUENAME_SONGS_PLAYED
drop table if exists dynamicplaylist_random_albums;
create temporary table dynamicplaylist_random_albums as
	select topavgrated.album as album from
		(select tracks.album as album, avg(ifnull(tracks_persistent.rating,0)) as avgrating, count(distinct tracks.id) as totaltrackcount from tracks
		left join library_track on
			library_track.track = tracks.id
		join tracks_persistent on
			tracks_persistent.urlmd5 = tracks.urlmd5
		left join dynamicplaylist_history on
			dynamicplaylist_history.id = tracks.id and dynamicplaylist_history.client = 'PlaylistPlayer'
		where
			tracks.audio = 1
			and tracks.year = 'PlaylistParameter1'
			and dynamicplaylist_history.id is null
			and
				case
					when ('PlaylistCurrentVirtualLibraryForClient' != '' and 'PlaylistCurrentVirtualLibraryForClient' is not null)
					then library_track.library = 'PlaylistCurrentVirtualLibraryForClient'
					else 1
				end
			and not exists (select * from tracks t2,genre_track,genres
							where
								t2.id = tracks.id and
								tracks.id = genre_track.track and
								genre_track.genre = genres.id and
								genres.name in ('PlaylistExcludedGenres'))
		group by tracks.album
			having totaltrackcount >= 'PlaylistMinAlbumTracks'
		order by avgrating desc, random()
		limit 30) as topavgrated
	order by random()
	limit 1;
select tracks.id, tracks.primary_artist from tracks
	join dynamicplaylist_random_albums on
		dynamicplaylist_random_albums.album = tracks.album
	join tracks_persistent on
		tracks_persistent.urlmd5 = tracks.urlmd5
	left join library_track on
		library_track.track = tracks.id
	left join dynamicplaylist_history on
		dynamicplaylist_history.id = tracks.id and dynamicplaylist_history.client = 'PlaylistPlayer'
	where
		tracks.audio = 1
		and tracks.secs >= 'PlaylistTrackMinDuration'
		and dynamicplaylist_history.id is null
		and
			case
				when 'PlaylistParameter2' = 1 then ifnull(tracks_persistent.playCount, 0) = 0
				when 'PlaylistParameter2' = 2 then ifnull(tracks_persistent.playCount, 0) > 0
				else 1
			end
		and
			case
				when ('PlaylistCurrentVirtualLibraryForClient' != '' and 'PlaylistCurrentVirtualLibraryForClient' is not null)
				then library_track.library = 'PlaylistCurrentVirtualLibraryForClient'
				else 1
			end
		and not exists (select * from tracks t2,genre_track,genres
						where
							t2.id = tracks.id and
							tracks.id = genre_track.track and
							genre_track.genre = genres.id and
							genres.name in ('PlaylistExcludedGenres'))
	group by tracks.id
	order by
		case
			when 'PlaylistTrackOrder' = 1 then "dynamicplaylist_random_albums.album, tracks.disc, tracks.tracknum"
		else
			"dynamicplaylist_random_albums.album, random()"
		end
	limit 'PlaylistLimit';
drop table dynamicplaylist_random_albums;
