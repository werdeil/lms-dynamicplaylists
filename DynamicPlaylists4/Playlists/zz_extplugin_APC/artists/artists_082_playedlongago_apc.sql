-- PlaylistName:PLUGIN_DYNAMICPLAYLISTS4_BUILTIN_PLAYLIST_ARTISTS_PLAYEDLONGAGO_APC
-- PlaylistGroups:Artists
-- PlaylistCategory:artists
-- PlaylistParameter1:list:PLUGIN_DYNAMICPLAYLISTS4_PARAMNAME_INCLUDESONGS:0:PLUGIN_DYNAMICPLAYLISTS4_PARAMVALUENAME_SONGS_ALL,1:PLUGIN_DYNAMICPLAYLISTS4_PARAMVALUENAME_SONGS_UNPLAYED,2:PLUGIN_DYNAMICPLAYLISTS4_PARAMVALUENAME_SONGS_PLAYED
drop table if exists dynamicplaylist_random_contributors;
create temporary table dynamicplaylist_random_contributors as
	select contributor_track.contributor as contributor, count(distinct tracks.id) as totaltrackcount from tracks
		join contributor_track on
			contributor_track.track = tracks.id and contributor_track.role in (1,4,5,6)
		join alternativeplaycount on
			alternativeplaycount.urlmd5 = tracks.urlmd5
		left join library_track on
			library_track.track = tracks.id
		left join dynamicplaylist_history on
			dynamicplaylist_history.id = tracks.id and dynamicplaylist_history.client = 'PlaylistPlayer'
		where
			tracks.audio = 1
			and dynamicplaylist_history.id is null
			and contributor_track.contributor != 'PlaylistVariousArtistsID'
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
		group by contributor_track.contributor
			having
				totaltrackcount >= 'PlaylistMinArtistTracks'
				and ((strftime('%s',DATE('NOW','-'PlaylistPeriodPlayedLongAgo' YEAR'))-max(ifnull(alternativeplaycount.lastPlayed,0))) > 0)
		order by random()
		limit 1;
select tracks.id, tracks.primary_artist from tracks
	join contributor_track on
		contributor_track.track = tracks.id and contributor_track.role in (1,4,5,6)
	join dynamicplaylist_random_contributors on
		dynamicplaylist_random_contributors.contributor = contributor_track.contributor
	join alternativeplaycount on
		alternativeplaycount.urlmd5 = tracks.urlmd5
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
				when 'PlaylistParameter1' = 1 then ifnull(alternativeplaycount.playCount, 0) = 0
				when 'PlaylistParameter1' = 2 then ifnull(alternativeplaycount.playCount, 0) > 0
				else 1
			end
		and
			case
				when ('PlaylistCurrentVirtualLibraryForClient' != '' and 'PlaylistCurrentVirtualLibraryForClient' is not null)
				then library_track.library = 'PlaylistCurrentVirtualLibraryForClient'
				else 1
			end
		and not exists (select * from tracks t2, genre_track, genres
						where
							t2.id = tracks.id and
							tracks.id = genre_track.track and
							genre_track.genre = genres.id and
							genres.name in ('PlaylistExcludedGenres'))
	group by tracks.id
	order by dynamicplaylist_random_contributors.contributor, random()
	limit 'PlaylistLimit';
drop table dynamicplaylist_random_contributors;
