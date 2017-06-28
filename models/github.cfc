/**
* I interact with GitHub
*/
component accessors="true" singleton {
	property name='log' inject='logbox:logger:{this}'; 
	property name='cache' inject='cachebox:default'; 
	property name='settings' inject='coldbox:configSettings'; 

	/**
	* Get Adobe GitHub data
	*/
	public struct function getRepos() {
		// Retrive item from cache, creating it if neccessary.
		return cache.getOrSet( 
			'gitRepos',
			function() {
				log.info( 'updated_man_github,  #datetimeFormat( now() )#' );
				return buildRepos();
			},
			settings.freqReload
		);
	
	}	

	
	/**
	* Get cached list of JSON Adobe orgs from GitHub
	*/
	private array function getOrgs() {
		log.info( 'get_orgs, #datetimeFormat( now() )#' );
		
		var thisURL = 'https://raw.githubusercontent.com/adobe/adobe.github.com/master/data/org.json';
		var results = {};
		
		cfhttp( url="#thisURL#", useragent='server.adobe.com', result="local.results" );

		if ( results.statusCode contains '200' ) {
			return deserializeJSON( results.fileContent );
		} else {
			log.error( 'error for #thisURL#, #results.statusCode#, #results.fileContent#, #datetimeFormat( now() )#' );
			return {};
		}
		
	}
	
	/**
	* Build repo data
	*/
	private struct function buildRepos() {		
		var thisDate = dateConvert( "local2utc", now() );
		// Template for repo data
		// variables scoped so threads can all access without duplication		
		data = {
					'lastUpdate' : toString( dateFormat( thisDate, "yyyy-mm-dd" ) & "T" & timeFormat( thisDate, "HH:mm:ss" ) & "Z" ),
					'stats' : {
						'bitesCode' : 0,
						'bitesLangCode' : 0
					},
					'repos' : [],
					'langs' : [],
					'orgs' : getOrgs()
				};
		
	//	var threads = '';
		
		data.orgs.each( function( org ) {
			
		//	threads = threads.listAppend( 'org-#org.userName#' );
			
		//	cfthread( name="org-#org.userName#", action='run', org=org ) {
			//	try {
				
					// Get details for each org
					var orgData = doGithubCall( '/orgs/' & org.userName );
					org.append( {
						avatar_url : orgData.avatar_url,
						blog : orgData.blog ?: '',
						html_url : orgData.html_url,
						public_repos : orgData.public_repos,
						updated_at : orgData.updated_at
					} );
					
					// Get repos for this org
					var repoData = doGithubCall( '/users/' & org.userName & '/repos?sort=updated' );
					repoData.each( function( repo ){
						var thisStats = data.stats;
						
						var thisRepo = {
							'name' : repo.name,
							'watchers_count' : repo.watchers_count,
							'org' : getOrgFullName( data.orgs, repo.owner.login ),
							'languages' : [],
							'languagesTotal' : 0,
							'description' : repo.description ?: '',
							'size' : repo.size,
							'pushed_at' : repo.pushed_at,
							'html_url' : repo.html_url,
							'languages_url' : repo.languages_url,
							'homepage' : repo.homepage ?: ''
						  };
						
						// Get languages used for this repo
						var repoLangs = doGithubCall( repo.languages_url.mid( 23, repo.languages_url.len() ) );
						for( var lang in repoLangs ) {
							thisLang = {
								'name' : lang,
								'value' : repoLangs[ lang ]
							};
							// Add language to repo
							thisRepo.languages.append( thisLang );
							// Increment counter for this repo
							thisRepo.languagesTotal += thisLang.value;
							// Increment global counter for all repos
							thisStats.bitesLangCode += thisLang.value;
							// Add language to global list
							addLanguageTotal( data.langs, thisLang );
						}
						
						// Increment global repo size
						thisStats.bitesCode += thisRepo.size;
						// Append repo to total list
						data.repos.append( thisRepo );  			  
					} ); // End loop over repos.
					
			//	} catch( any e ) {
			//		log.error( e );
			//	}	
				
		//	} // End thread
			
		} ); // End loop over orgs
		
	//	cfthread( action='join', name=threads );
		
		return data;
	}
	
	/**
	* Match org login to full name
	*/
	private function getOrgFullName( orgs, userName ) {
		// Find the org with this userName
		for( var org in orgs ) {
			if( userName == org.userName ) {
				return org.name;
			}
		}
		return '';
	}
	
	/**
	* Add language to global stats
	*/
	private function addLanguageTotal( langs, newLang ) {
		// If language exists, add our total to it.
		for( var lang in langs ) {
			if( lang.name == newLang.name ) {
				lang.value += newLang.value;
				return;
			}
		}
		// Otherwise just add the language
		langs.append( newLang );
	}
	
	/**
	* Make call to GitHub
	*/
	private function doGithubCall( required string path ) {
		
		var results = {};
		
		cfhttp( 
			url = "https://api.github.com#path#",
			useragent = 'server.adobe.com',
			result = "local.results",
			username = settings.GHUser,
			password = settings.GHPass );
	
		if ( results.statusCode contains '200' ) {
			return deserializeJSON( results.fileContent );
		} else {
			log.error( 'error for api.github.com#path#", #results.statusCode#, #results.fileContent#, #datetimeFormat( now() )#' );
			throw( message='GitHub API unreachable. ' & ( results.responseHeader.status ?: 'ERROR' ) );
			}
		
	
	}


}