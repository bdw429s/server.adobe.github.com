server.adobe.github.com
=======================

Manage API calls on github to pull Adobe information using an [Adobe ColdFusion](http://www.adobe.com/products/coldfusion-family.html) REST API.

# Start

After installing dependencies with `box install`, you can launch the server with:

```
box start
```

# Use

Here is the route you can call:

- `/` : every Adobe organisations, repositories, languages used on github.

# Config


## GitHub account

In order for the app to make Github API calls without reaching the limit, you need to authentificate.

The ID and pass are pulled from the local environment variables. Add those lines in your `~/.bashrc`:

```
export GHUSER=[userName]
export GHPASS=[userPassword]
```

## Production

Once you push your server in production, you need to update your environment variable CFML_ENV. 

```
export CFML_ENV=production
```

## Port managing

The default port is 5000. To be able to call on 80 modify your `server.json`.

```
box start port=80
```
