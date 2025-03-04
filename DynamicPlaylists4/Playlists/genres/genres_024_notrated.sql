-- PlaylistName:PLUGIN_DYNAMICPLAYLISTS4_BUILTIN_PLAYLIST_GENRES_UNRATED
-- PlaylistGroups:Genres
-- PlaylistCategory:genres
-- PlaylistParameter1:list:PLUGIN_DYNAMICPLAYLISTS4_PARAMNAME_INCLUDESONGS:0:PLUGIN_DYNAMICPLAYLISTS4_PARAMVALUENAME_SONGS_ALL,1:PLUGIN_DYNAMICPLAYLISTS4_PARAMVALUENAME_SONGS_UNPLAYED,2:PLUGIN_DYNAMICPLAYLISTS4_PARAMVALUENAME_SONGS_PLAYED
drop table if exists dynamicplaylist_random_genres;
create temporary table dynamicplaylist_random_genres as
	select notrated.genre as genre, notrated.sumrating as sumrating from
		(select genre_track.genre as genre, sum(ifnull(tracks_persistent.rating,0)) as sumrating from genre_track
			join tracks on
				genre_track.track = tracks.id
			left join library_track on
				library_track.track = tracks.id
			join tracks_persistent on
				tracks_persistent.urlmd5 = tracks.urlmd5
			left join dynamicplaylist_history on
				dynamicplaylist_history.id = tracks.id and dynamicplaylist_history.client = 'PlaylistPlayer'
			where
				genre_track.genre is not null
				and dynamicplaylist_history.id is null
				and not exists (select * from tracks t2,genre_track,genres
								where
									t2.id = tracks.id and
									tracks.id = genre_track.track and
									genre_track.genre = genres.id and
									genres.name in ('PlaylistExcludedGenres'))
				and
					case
						when ('PlaylistCurrentVirtualLibraryForClient' != '' and 'PlaylistCurrentVirtualLibraryForClient' is not null)
						then library_track.library = 'PlaylistCurrentVirtualLibraryForClient'
						else 1
					end
			group by genre_track.genre
				having sumrating = 0
			order by sumrating asc, random()
			limit 30) as notrated
	where sumrating = 0
	order by random()
	limit 1;
select tracks.id, tracks.primary_artist from tracks
	join genre_track on
		genre_track.track = tracks.id
	join dynamicplaylist_random_genres on
		dynamicplaylist_random_genres.genre = genre_track.genre
	join tracks_persistent on
		tracks_persistent.urlmd5 = tracks.urlmd5
	left join library_track on
		library_track.track = tracks.id
	left join dynamicplaylist_history on
		dynamicplaylist_history.id = tracks.id and dynamicplaylist_history.client = 'PlaylistPlayer'
	where
		tracks.audio = 1
		and dynamicplaylist_history.id is null
		and tracks.secs >= 'PlaylistTrackMinDuration'
		and
			case
				when 'PlaylistParameter1' = 1 then ifnull(tracks_persistent.playCount, 0) = 0
				when 'PlaylistParameter1' = 2 then ifnull(tracks_persistent.playCount, 0) > 0
				else 1
			end
		and
			case
				when ('PlaylistCurrentVirtualLibraryForClient' != '' and 'PlaylistCurrentVirtualLibraryForClient' is not null)
				then library_track.library = 'PlaylistCurrentVirtualLibraryForClient'
				else 1
			end
	group by tracks.id
	order by random()
	limit 'PlaylistLimit';
drop table dynamicplaylist_random_genres;
