-- PlaylistName:PLUGIN_DYNAMICPLAYLISTS3_BUILTIN_PLAYLIST_CONTEXT_GENRE_ALBUMS_NEVERPLAYED_APC
-- PlaylistGroups:Context menu lists/ genre
-- PlaylistMenuListType:contextmenu
-- PlaylistCategory:genres
-- PlaylistTrackOrder:ordered
-- PlaylistLimitOption:unlimited
-- PlaylistParameter1:genre:PLUGIN_DYNAMICPLAYLISTS3_PARAMNAME_SELECTGENRE:
drop table if exists dynamicplaylist_random_albums;
create temporary table dynamicplaylist_random_albums as
	select distinct tracks.album as album, sum(ifnull(alternativeplaycount.playCount,0)) as sumplaycount, count(distinct tracks.id) as totaltrackcount from tracks
		join genre_track on
			genre_track.track = tracks.id and genre_track.genre='PlaylistParameter1'
		left join library_track on
			library_track.track = tracks.id
		join alternativeplaycount on
			alternativeplaycount.urlmd5 = tracks.urlmd5
		left join dynamicplaylist_history on
			dynamicplaylist_history.id=tracks.id and dynamicplaylist_history.client='PlaylistPlayer'
		where
			tracks.audio = 1
			and dynamicplaylist_history.id is null
			and
				case
					when ('PlaylistCurrentVirtualLibraryForClient'!='' and 'PlaylistCurrentVirtualLibraryForClient' is not null)
					then library_track.library = 'PlaylistCurrentVirtualLibraryForClient'
					else 1
				end
		group by tracks.album
			having totaltrackcount >= 'PlaylistMinAlbumTracks' and sumplaycount = 0
		order by random()
		limit 1;
select distinct tracks.url from tracks
	join dynamicplaylist_random_albums on
		dynamicplaylist_random_albums.album = tracks.album
	join genre_track on
		genre_track.track = tracks.id and genre_track.genre='PlaylistParameter1'
	left join library_track on
		library_track.track = tracks.id
	left join dynamicplaylist_history on
		dynamicplaylist_history.id = tracks.id and dynamicplaylist_history.client='PlaylistPlayer'
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
	order by
		case
			when 'PlaylistTrackOrder' = 1 then "dynamicplaylist_random_albums.album, tracks.disc, tracks.tracknum"
		else
			"dynamicplaylist_random_albums.album, random()"
		end
	limit 'PlaylistLimit';
drop table dynamicplaylist_random_albums;
