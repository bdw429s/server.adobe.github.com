component{

	variables.system = createObject( "java", "java.lang.System" );
	
	// Configure ColdBox Application
	function configure(){

		// coldbox directives
		coldbox = {
			//Application Setup
			appName 				= "server.adobe.github.com",

			defaultEvent			= "Adobe.index",
			customErrorTemplate		= "/includes/error.cfm",

			eventCaching			= true,
			viewCaching				= true
		};

		// custom settings
		settings = {
			GHUser = getSystemSetting( 'GHUSER', '' ),
			GHPass = getSystemSetting( 'GHPASS', '' ),
			freqReload = getSystemSetting( 'GHFREQRELOAD', 60 )
		};

		//LogBox DSL
		logBox = {
			// Define Appenders
			appenders = {
				coldboxTracer = { class="coldbox.system.logging.appenders.ConsoleAppender" }
			},
			// Root Logger
			root = { levelmax="INFO", appenders="*" },
			// Implicit Level Categories
			info = [ "coldbox.system" ]
		};

		//Register interceptors as an array, we need order
		interceptors = [
			{ class="coldbox.system.interceptors.SES" }
		];

	}

	/**
	* Development environment
	*/
	function development(){
		coldbox.customErrorTemplate = "/coldbox/system/includes/BugReport.cfm";
		coldbox.reinitPassword = '';
	}

	function detectEnvironment() {
		return getSystemSetting( 'ENVIRONMENT', 'development' );
	}

	/**
	* Retrieve a Java System property or env value by name.
	*
	* @key The name of the setting to look up.
	* @defaultValue The default value to use if the key does not exist in the system properties
	*/
    function getSystemSetting( required string key, defaultValue ) {
		
		var value = system.getProperty( arguments.key );
		if ( ! isNull( value ) ) {
			return value;
		}
		
		value = system.getEnv( arguments.key );
		if ( ! isNull( value ) ) {
			return value;
		}

		if ( ! isNull( arguments.defaultValue ) ) {
			return arguments.defaultValue;
		}

		return '';
	}
}