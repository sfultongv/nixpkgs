''
# name of the dispatcher
/name "rwjf-dispatcher"

# Each farm configures a set of load balanced renders (i.e. remote servers)
/farms
	{
	# Publish farm entry
	/publish
		{
		# Request headers that should be forwarded to the remote server.
		/clientheaders
			{
			# Forward all request headers that are end-to-end. If you want
			# to forward a specific set of headers, you'll have to list
			# them here.
			"*"
			}

		# Hostname globbing for farm selection (virtual domain addressing)
		/virtualhosts
			{
			# Entries will be compared against the "Host" request header
			# and an optional request URL prefix.
			#
			# Examples:
			#
			#   www.company.com
			#   intranet.*
			#   myhost:8888/mysite
			"*"
			}

		# The load will be balanced among these render instances
		/renders
			{
			/publish01
				{
				# Hostname or IP of the render
				/hostname "localhost"
				# Port of the render
				/port "4503"
				# Connect timeout in milliseconds, 0 to wait indefinitely
				/timeout "30000"
				}
			}

		# The filter section defines the requests that should be handled by the dispatcher.
		# The globs will be compared against the request line, e.g. "GET /index.html HTTP/1.1".
		/filter
			{
			# Deny everything first and then allow specific entries
			/0001 { /type "deny"  /glob "*" }

			# Open consoles
			#/0011 { /type "allow" /glob "* /admin/*"  }  # allow servlet engine admin
			#/0012 { /type "allow" /glob "* /crx/*"    }  # allow content repository
			#/0013 { /type "allow" /glob "* /system/*" }  # allow OSGi console

			# Allow non-public content directories
			#/0021 { /type "allow" /glob "* /apps/*"   }  # allow apps access
			#/0022 { /type "allow" /glob "* /bin/*"    }
			/0023 { /type "allow" /glob "GET / *" } # allow root to pass, but only the root.
			/0024 { /type "allow" /glob "GET /index.html *" } # allow our default root page.
			/0025 { /type "allow" /glob "GET /content*" }  # disable this rule to allow mapped content only
			/0026 { /type "allow" /glob "GET /rwjf*" }
			/0027 { /type "allow" /glob "GET /en*" }
			/0028 { /type "allow" /glob "GET /feature_cards*" }
			/0029 { /type "allow" /glob "GET /css*" }
			/0030 { /type "allow" /glob "GET /js*" }
			/0031 { /type "allow" /glob "GET /images*" }
			/0032 { /type "allow" /glob "GET /jtemplates*" }
			/0033 { /type "allow" /glob "GET /xd_receiver.htm*" }
			/0034 { /type "allow" /glob "GET /preview*" }
			/0035 { /type "allow" /glob "GET /at40*" }
			/0036 { /type "allow" /glob "GET /futureofhealth*" }

			#/0040 { /type "allow" /glob "* /libs/*"   }
			#/0041 { /type "deny"  /glob "* /libs/shindig/proxy*" } # if you enable /libs close access to proxy

			#/0042 { /type "allow" /glob "* /home/*"   }
			#/0043 { /type "allow" /glob "* /tmp/*"    }
			#/0044 { /type "allow" /glob "* /var/*"    }

			# Enable access required for cloud services
			/0045 { /type "allow" /glob "GET /etc/clientcontext/legacy/config.init.js*" }
			/0046 { /type "allow" /glob "GET /etc/clientcontext/legacy/config.json*" }
			/0047 { /type "allow" /glob "GET /etc/clientcontext/default/content/jcr:content/stores.init.js*" }
			/0048 { /type "allow" /glob "GET /libs/cq/i18n/dict.en.json*" }
			/0049 { /type "allow" /glob "GET /libs/cq/security/userinfo.json*" }

			# Enable specific mime types in non-public content directories
			/0051 { /type "allow" /glob "GET *.css *"   }  # enable css
			/0052 { /type "allow" /glob "GET *.gif *"   }  # enable gifs
			/0053 { /type "allow" /glob "GET *.ico *"   }  # enable icos
			/0054 { /type "allow" /glob "GET *.js *"    }  # enable javascript
			/0055 { /type "allow" /glob "GET *.png *"   }  # enable png
			/0056 { /type "allow" /glob "GET *.swf *"   }  # enable flash
			/0057 { /type "allow" /glob "GET *.jpg *"   }  # enable jpg

			# Enable features
			/0061 { /type "allow" /glob "POST /content/[.]*.form.html" }  # allow POSTs to form selectors under content
			/0062 { /type "allow" /glob "GET /libs/cq/personalization/*"  }  # enable personalization
			/0063 { /type "allow" /glob "GET /libs/wcm/stats/tracker.js*" } #enable page tracking

			# Deny content grabbing
			/0081 { /type "deny"  /glob "GET *.infinity.json*" }
			/0082 { /type "deny"  /glob "GET *.tidy.json*"     }
			/0083 { /type "deny"  /glob "GET *.sysview.xml*"   }
			/0084 { /type "deny"  /glob "GET *.docview.json*"  }
			/0085 { /type "deny"  /glob "GET *.docview.xml*"  }

			/0086 { /type "deny"  /glob "GET *.*[0-9].json*" }
			#/0087 { /type "allow" /glob "GET *.1.json*" }          # allow one-level json requests
			/0088 { /type "deny"  /glob "GET *.feed.xml*" }
			/0089 { /type "deny"  /glob "GET *.feed*" }

			# Deny query
			/0090 { /type "deny"  /glob "* *.query.json*" }

			# Allow Legacy URLs so we can redirect them
			/0135 { /type "allow" /glob "GET /about*" }
			/0136 { /type "allow" /glob "GET /childhoodobesity*" }
			/0137 { /type "allow" /glob "GET /coverage*" }
			/0138 { /type "allow" /glob "GET /grantees*" }
			/0139 { /type "allow" /glob "GET /grants*" }
			/0140 { /type "allow" /glob "GET /healthpolicy*" }
			/0141 { /type "allow" /glob "GET /humancapital*" }
			/0142 { /type "allow" /glob "GET /multicultural*" }
			/0143 { /type "allow" /glob "GET /newsroom*" }
			/0144 { /type "allow" /glob "GET /patterson*" }
			/0145 { /type "allow" /glob "GET /pioneer*" }
			/0146 { /type "allow" /glob "GET /pr*" }
			/0147 { /type "allow" /glob "GET /publichealth*" }
			/0148 { /type "allow" /glob "GET /qualityequality*" }
			/0149 { /type "allow" /glob "GET /video*" }
			/0150 { /type "allow" /glob "GET /vulnerablepopulations*" }
			/0151 { /type "allow" /glob "GET /goto*" }
			/0152 { /type "allow" /glob "GET /applications/solicited/cfp.jsp*" }

			# Allow RSS Links
			/0153 { /type "allow" /glob "GET /rss*" }

			# Allow Grant Map API
			/0154 { /type "allow" /glob "GET /api/*" }

			# Allow RWJF Action servlet
            /0155 { /type "allow" /glob "GET /action/*" }

			# Allow Sitemap and Robots.txt
			/0200 { /type "allow" /glob "GET /sitemap.xml*" }
			/0201 { /type "allow" /glob "GET /robots.txt*" }

			# Deny .export.zip
			/0203 { /type "deny"  /glob "GET *.export.zip*" }
			
			# Allow the favicon directly so we can use ?v to force browser to ignore cache
			/0204 { /type "allow" /glob "GET /etc/designs/rwjf/favicon.ico*" }

			# Allow Client Contexts introduced in 5.6
			/0205 { /type "allow" /glob "GET /etc/clientcontext/default/contextstores/twitterprofiledata/loader.json*" }
			/0206 { /type "allow" /glob "GET /etc/clientcontext/default/contextstores/fbprofiledata/loader.json*" }
			/0207 { /type "allow" /glob "GET /etc/clientcontext/default/contextstores/fbinterestsdata/loader.json*" }

			# Allow newsletters
			/0208 { /type "allow" /glob "GET /etc/newsletters/*" }

			# Allow Akamai test page
			/0209 { /type "allow" /glob "GET /etc/akamai/akamai-test-object.html*" }

			# Special POST Rules
			/0300 { /type "allow" /glob "POST /action/contactlist/sendContactForm *" }
			/0301 { /type "allow" /glob "POST /api/addsubscription *" }
			/0302 { /type "allow" /glob "POST /api/manageSubscriptions *" }
			/0303 { /type "allow" /glob "POST */j_security_check *" }
			/0304 { /type "allow" /glob "POST /content/rwjf/en/manage-subscriptions/_jcr_content.confirm.html *" }
			
			}

		#/sessionmanagement
		#	{
		#	/directory "/tmp/publish.sessions"
		#	}

		# The cache section regulates what responses will be cached and where.
		/cache
			{
			# The docroot must be equal to the document root of the webserver. The
			# dispatcher will store files relative to this directory and subsequent
			# requests may be "declined" by the dispatcher, allowing the webserver
			# to deliver them just like static files.
			/docroot "/srv/www/htdocs/pub"

			# Sets the level upto which files named ".stat" will be created in the
			# document root of the webserver. When an activation request for some
			# page is received, only files within the same subtree are affected
			# by the invalidation.
			/statfileslevel "4"

			# Flag indicating whether to cache responses to requests that contain
			# authorization information.
			#/allowAuthorized "0"

			# Flag indicating whether the dispatcher should serve stale content if
			# no remote server is available.
			#/serveStaleOnError "0"

			# The rules section defines what responses should be cached based on
			# the requested URL. Please note that only the following requests can
			# lead to cacheable responses:
			#
			# - HTTP method is GET
			# - URL has an extension
			# - Request has no query string
			# - Request has no "Authorization" header (unless allowAuthorized is 1)
			/rules
				{
				/0000
					{
					# the globbing pattern to be compared against the url
					# example: *             -> everything
					#        : /foo/bar.*    -> only the /foo/bar documents
					#        : /foo/bar/*    -> all pages below /foo/bar
					#        : /foo/bar[./]* -> all pages below and /foo/bar itself
					#        : *.html        -> all .html files
					/glob "*"
					/type "allow"
					}
				/0001
					{
					/glob "*.tweets.json"
					/type "deny"
					}
				/0002
					{
					/glob "/content/rwjf/en/grants/calls-for-proposals*"
					/type "deny"
					}
				/0003
					{
					/glob "/robots.txt*"
					/type "deny"
					}
				/0004
					{
					/glob "/goto2*"
					/type "deny"
					}
				/0005
					{
					/glob "*.nocache.html*"
					/type "deny"					
					}
				}

			# The invalidate section defines the pages that are "invalidated" after
			# any activation. Please note that the activated page itself and all
			# related documents are flushed on an modification. For example: if the
			# page /foo/bar is activated, all /foo/bar.* files are removed from the
			# cache.
			/invalidate
				{
				/0000
					{
					/glob "*"
					/type "deny"
					}
				/0001
					{
					# Consider all HTML files stale after an activation.
					/glob "*.html"
					/type "allow"
					}
				/0002
					{
					# Consider rss feeds stale after an activation.
					/glob "*.rssfeed"
					/type "allow"
					}
				}

			# The allowedClients section restricts the client IP addresses that are
			# allowed to issue activation requests.
			/allowedClients
				{
				# Uncomment the following to restrict activation requests to originate
				# from "localhost" only.
				#
				/0000
					{
					/glob "*"
					/type "allow"
					}
				/0001
					{
					/glob "127.0.0.1"
					/type "allow"
					}
				}
			}

		# The statistics sections dictates how the load should be balanced among the
		# renders according to the media-type.
		/statistics
			{
			/categories
				{
				/html
					{
					/glob "*.html"
					}
				/others
					{
					/glob "*"
					}
				}
			}
		}

	# Authoring farm entry
	/authoring
		{
		# Request headers that should be forwarded to the remote server.
		/clientheaders
			{
			# Forward a specific set of headers.
			"destination"
			"depth"
			"lock-token"
			"overwrite"
			"dav"
			"if"
			"referer"
			"user-agent"
			"authorization"
			"from"
			"content-type"
			"content-length"
			"accept-charset"
			"accept-encoding"
			"accept-language"
			"accept"
			"host"
			"if-match"
			"if-none-match"
			"if-range"
			"if-unmodified-since"
			"max-forwards"
			"proxy-authorization"
			"proxy-connection"
			"range"
			"cookie"
			"cq-action"
			"cq-handle"
			"handle"
			"action"
			"cqstats"
			"x-http-method-override"
			"x-requested-with"
			}

		# Hostname globbing for farm selection (virtual domain addressing)
		/virtualhosts
			{
			# Entries will be compared against the "Host" request header
			# and an optional request URL prefix.
			#
			# Examples:
			#
			#   www.company.com
			#   intranet.*
			#   myhost:8888/mysite
			"authoring.rwjf-trunk.christopherl.com"
			}

		# The load will be balanced among these render instances
		/renders
			{
			/authoring01
				{
				# Hostname or IP of the render
				/hostname "localhost"
				# Port of the render
				/port "4502"
				# Connect timeout in milliseconds, 0 to wait indefinitely
				/timeout "100000"
				}
			}

		# The filter section defines the requests that should be handled by the dispatcher.
		# The globs will be compared against the request line, e.g. "GET /index.html HTTP/1.1".
		/filter
			{
			/0000
				{
				/glob "*"
				/type "allow"
				}
			# Deny external access to system console
			#/0001
			#	{
			#	/glob "* /system/*"
			#	/type "deny"
			#	}
			# Deny external access to CRX web application
			#/0002
			#	{
			#	/glob "* /crx*"
			#	/type "deny"
			#	}
			# Deny external access to servlet engine console
			#/0003
			#	{
			#	/glob "* /admin/*"
			#	/type "deny"
			#	}
			}

		# enable session management
		/sessionmanagement
			{
			/directory "/tmp/author.sessions"
			}

		# deny propagation of replication posts
		/propagateSyndPost "0"

		# The cache section regulates what responses will be cached and where.
		/cache
			{
			# The docroot must be equal to the document root of the webserver. The
			# dispatcher will store files relative to this directory and subsequent
			# requests may be "declined" by the dispatcher, allowing the webserver
			# to deliver them just like static files.
			/docroot "/srv/www/htdocs/auth"

			# Sets the level upto which files named ".stat" will be created in the
			# document root of the webserver. When an activation request for some
			# page is received, only files within the same subtree are affected
			# by the invalidation.
			/statfileslevel "0"

			# Flag indicating whether to cache responses to requests that contain
			# authorization information.
			/allowAuthorized "0"

			# Flag indicating whether the dispatcher should serve stale content if
			# no remote server is available.
			#/serveStaleOnError "0"

			# The rules section defines what responses should be cached based on
			# the requested URL. Please note that only the following requests can
			# lead to cacheable responses:
			#
			# - HTTP method is GET
			# - URL has an extension
			# - Request has no query string
			# - Request has no "Authorization" header (unless allowAuthorized is 1)
			/rules
				{
				/0000
					{
					/glob "*"
					/type "deny"
					}
				/0001
					{
					/glob "/libs/*"
					/type "allow"
					}
				/0002
					{
					/glob "/apps/*"
					/type "allow"
					}
				/0003
					{
					# This page contains a "Welcome, User XXX" message
					/glob "/libs/cq/core/content/welcome.html"
					/type "deny"
					}
				}

			# The invalidate section defines the pages that are "invalidated" after
			# any activation. Please note that the activated page itself and all
			# related documents are flushed on an modification. For example: if the
			# page /foo/bar is activated, all /foo/bar.* files are removed from the
			# cache.
			/invalidate
				{
				/0000
					{
					/glob "*"
					/type "deny"
					}
				/0001
					{
					# Consider all HTML files stale after an activation.
					/glob "*.html"
					/type "allow"
					}
				}
			}

		# The statistics sections dictates how the load should be balanced among the
		# renders according to the media-type.
		/statistics
			{
			/categories
				{
				/html
					{
					/glob "*.html"
					}
				/others
					{
					/glob "*"
					}
				}
			}
		}
	}

''
