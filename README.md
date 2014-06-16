# EmberFire (Firebase + Ember Data)

EmberFire is an officially supported adapter for using
[Firebase](http://www.firebase.com/?utm_medium=web&utm_source=emberFire) with
[Ember Data](https://github.com/emberjs/data).

The `DS.FirebaseAdapter` provides all of the standard `DS.Adapter` methods and will automatically synchronize the store with Firebase.

If you would like to use Firebase without Ember Data, we recommend the third-party [ember-firebase](https://github.com/mjijackson/ember-firebase) binding.

**Join the [Firebase + Ember Google Group](https://groups.google.com/forum/#!forum/firebase-ember) to ask technical questions, share apps you've built, and chat with other developers in the community**

## Installation

```html
<!-- Don't forget to include Ember and its dependencies -->
<script src="http://builds.emberjs.com/canary/ember-data.js"></script>
<script src="https://cdn.firebase.com/js/client/1.0.6/firebase.js"></script>
<script src="emberfire.js"></script>
```

#### Note

If you load EmberFire with [Bower](https://github.com/firebase/emberFire), it will include ember-data automatically.

## Usage

To get started, simply create an instance of the
`DS.FirebaseAdapter` in your app:

```js
App.ApplicationAdapter = DS.FirebaseAdapter.extend({
  firebase: new Firebase('https://<my-firebase>.firebaseio.com')
});
```

Your Firebase data will now be synced with the Ember Data store

You can now interact with the data store as you normally would. For example,
calling `find()` with a specific ID will retrieve that record from Firebase.
Additionally, from that point on, every time that record is updated in Firebase,
it will automatically be updated in the local data store.

See the [Ember documentation](http://emberjs.com/guides/models/) for a full
list of methods, including ways to create, find, delete and query records.

#### Ember CLI

Run the following to add `emberfire.js` to your project:

```bash
bower install --save-dev emberfire
```

Add the following to your `Brocfile.js` (after importing Ember Data):

```javascript
app.import('vendor/firebase/firebase.js');
app.import('vendor/emberfire/dist/emberfire.js');
```

Create an **"app/adapters/application.js"** with the following content:

```javascript
/* globals Firebase */

export default DS.FirebaseAdapter.extend({
  firebase: new Firebase('https://<my-firebase>.firebaseio.com')
});
```

### Data Structure

By default, EmberFire will try to determine the correct Firebase reference based on the model name

```javascript
// Define a Post model
App.Post = DS.Model.extend();

// Records will be fetched from to https://<my-firebase>.firebaseio.com/posts
var posts = store.findAll('post');

// The new record will be saved to https://<my-firebase>.firebaseio.com/posts/post_id
var newPost = store.createRecord('post').save();
```

#### What if my data is named differently?

If you would like to customize where a model will be fetched/saved, simply create a model-specific adapter:

```javascript
// Define a Post model
App.Post = DS.Model.extend();

// Define a Post adapter
App.PostAdapter = App.ApplicationAdapter.extend({
  pathForType: function(type) {
    return 'custom-posts';
  }
});
```

Overriding the `pathForType` method will allow you to tell the adapter where it should fetch/save records of the specified type

```javascript
// Records will now be fetched from to https://<my-firebase>.firebaseio.com/custom-posts
var posts = store.findAll('post');

// The new record will now be saved to https://<my-firebase>.firebaseio.com/custom-posts/post_id
var newPost = store.createRecord('post').save();
```

### Relationships

EmberFire can handle relationships in two different ways

#### Async

Any relationship that is flagged as `async: true` tells the adapter to fetch
the record if it hasn't already been loaded

```js
App.Post = DS.Model.extend({
  comments: DS.hasMany('comment', { async: true })
});

App.Comment = DS.Model.extend({
  post: DS.belongsTo('post', { async: true })
});
```

In the `App.Post` example, comments will be fetched from
`https://<my-firebase>.firebaseio.com/comments`

Here is what the data structure would look in Firebase:

```json
{
  "posts": {
    "post_id_1": {
      "comments": {
        "comment_id_1": true
      }
    }
  },

  "comments": {
    "comment_id_1": {
      "body": "This is a comment",
      "post": "post_id_1"
    }
  }
}
```

**NOTE:** If your async data isn't autoloading, make sure you've defined your relationships in both directions.

#### Embedded

Any relationship that is flagged as `embedded: true` tells the adapter
that the related records have been included in the payload.

Generally, this approach is more complicated and not as widely used,
but it has been included to support existing data structures.

```js
App.Post = DS.Model.extend({
  comments: DS.hasMany('comment', { embedded: true })
});
```

Here is what the data structure would look like in Firebase:

```json
{
  "posts": {
    "post_id_1": {
      "comments": {
        "comment_id_1": {
          "body": "This is a comment"
        }
      }
    }
  }
}
```

**NOTE**: When a model has embedded relationships, the related model should not be saved on its own.

```js
var comment = store.createRecord('comment');
// This WILL NOT save the comment inside of the post because the adapter doesn't know
// where to save the comment without the context of the post
comment.save();
```

Instead, the comment needs to be added to the post
and then the post can be saved

```js
// Add the new comment to the post and save it
post.get('comments').addObject(comment);
// Saving the post will save the embedded comments
post.save()
```

## Development

If you would like to build EmberFire from the source, use grunt to build and lint the code:

```bash
# Install Grunt and development dependencies
npm install
# Default task - validates with jshint, minifies source, and runs tests
grunt
# Watch for changes and run unit test after each change
grunt watch
# Minify source
grunt build
```

## License

[MIT](http://firebase.mit-license.org).
