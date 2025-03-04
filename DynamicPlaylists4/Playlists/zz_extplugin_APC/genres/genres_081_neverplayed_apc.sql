-- PlaylistName:PLUGIN_DYNAMICPLAYLISTS4_BUILTIN_PLAYLIST_GENRES_NEVERPLAYED_APC
-- PlaylistGroups:Genres
-- PlaylistCategory:genres
drop table if exists dynamicplaylist_random_genres;
create temporary table dynamicplaylist_random_genres as
	select genre_track.genre as genre, sum(ifnull(alternativeplaycount.playCount,0)) as sumplaycount from genre_track
		join tracks on
			genre_track.track = tracks.id
		left join library_track on
			library_track.track = tracks.id
		join alternativeplaycount on
			alternativeplaycount.urlmd5 = tracks.urlmd5
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
			having sumplaycount = 0
		order by random()
		limit 1;
select tracks.id, tracks.primary_artist from tracks
	join genre_track on
		genre_track.track = tracks.id
	join dynamicplaylist_random_genres on
		dynamicplaylist_random_genres.genre = genre_track.genre
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
				when ('PlaylistCurrentVirtualLibraryForClient' != '' and 'PlaylistCurrentVirtualLibraryForClient' is not null)
				then library_track.library = 'PlaylistCurrentVirtualLibraryForClient'
				else 1
			end
	group by tracks.id
	order by random()
	limit 'PlaylistLimit';
drop table dynamicplaylist_random_genres;
