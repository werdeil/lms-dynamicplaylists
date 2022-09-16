-- PlaylistName:PLUGIN_DYNAMICPLAYLISTS3_BUILTIN_PLAYLIST_CONTEXT_GENRE_SONGS_PERCENTAGERATED
-- PlaylistGroups:Context menu lists/ genre
-- PlaylistMenuListType:contextmenu
-- PlaylistCategory:genres
-- PlaylistParameter1:genre:PLUGIN_DYNAMICPLAYLISTS3_PARAMNAME_SELECTGENRE:
-- PlaylistParameter2:list:PLUGIN_DYNAMICPLAYLISTS3_PARAMNAME_SELECTPERCENTAGERATED:0:0%,10:10%,20:20%,30:30%,40:40%,50:50%,60:60%,70:70%,80:80%,90:90%,100:100%
-- PlaylistParameter3:list:PLUGIN_DYNAMICPLAYLISTS3_PARAMNAME_INCLUDESONGS:0:PLUGIN_DYNAMICPLAYLISTS3_PARAMVALUENAME_SONGS_ALL,1:PLUGIN_DYNAMICPLAYLISTS3_PARAMVALUENAME_SONGS_UNPLAYED,2:PLUGIN_DYNAMICPLAYLISTS3_PARAMVALUENAME_SONGS_PLAYED
drop table if exists randomweightedratingshigh;
drop table if exists randomweightedratingslow;
drop table if exists randomweightedratingscombined;
create temporary table randomweightedratingslow as
	select distinct tracks.url as url from tracks
	join genre_track on
		genre_track.track = tracks.id and genre_track.genre='PlaylistParameter1'
	join tracks_persistent on
		tracks_persistent.urlmd5 = tracks.urlmd5 and (tracks_persistent.rating = 0 or tracks_persistent.rating is null)
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
				when 'PlaylistParameter3'=1 then ifnull(tracks_persistent.playCount, 0) = 0
				when 'PlaylistParameter3'=2 then ifnull(tracks_persistent.playCount, 0) > 0
				else 1
			end
		and
			case
				when ('PlaylistCurrentVirtualLibraryForClient'!='' and 'PlaylistCurrentVirtualLibraryForClient' is not null)
				then library_track.library = 'PlaylistCurrentVirtualLibraryForClient'
				else 1
			end
	group by tracks.id
	order by random()
	limit (100-'PlaylistParameter2');
create temporary table randomweightedratingshigh as
	select distinct tracks.url as url from tracks
	join genre_track on
		genre_track.track = tracks.id and genre_track.genre='PlaylistParameter1'
	join tracks_persistent on
		tracks_persistent.urlmd5 = tracks.urlmd5 and ifnull(tracks_persistent.rating, 0) > 0
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
				when 'PlaylistParameter3'=1 then ifnull(tracks_persistent.playCount, 0) = 0
				when 'PlaylistParameter3'=2 then ifnull(tracks_persistent.playCount, 0) > 0
				else 1
			end
		and
			case
				when ('PlaylistCurrentVirtualLibraryForClient'!='' and 'PlaylistCurrentVirtualLibraryForClient' is not null)
				then library_track.library = 'PlaylistCurrentVirtualLibraryForClient'
				else 1
			end
	group by tracks.id
	order by random()
	limit 'PlaylistParameter2';
create temporary table randomweightedratingscombined as select * from randomweightedratingslow union select * from randomweightedratingshigh;
	select * from randomweightedratingscombined
	order by random()
	limit 'PlaylistLimit';
drop table randomweightedratingshigh;
drop table randomweightedratingslow;
drop table randomweightedratingscombined;
