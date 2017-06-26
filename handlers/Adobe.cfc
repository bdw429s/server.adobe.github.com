/**
* My RESTFul Event Handler
*/
component extends="BaseHandler" {

	property name="github" inject="github";

	this.allowedMethods = {
		index='GET'
	};
	
	/**
	* Default Route
	*/
	function index( event, rc, prc ){
		log.info( 'query_recieved, From: #cgi.remote_addr#, #datetimeFormat( now() )#');
				
		prc.response
			.setData( [ github.getRepos() ] );
	}
	
}