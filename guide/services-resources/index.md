---
title: 'Services and Resources'
layout: default
---

# Services and Resources

Services and resources are your entry point for interaction with Siesta. Together, they represent a REST API and the many resources within it.

## Services

A [`Service`](http://bustoutsolutions.github.io/siesta/api/Classes/Service.html) represents an API, that is, a set of related resources which tend to share common rules about request and response structure, authentication, and other conventions.

You’ll typically create a `Service` singleton for each API your app uses:

```swift
let myAPI = Service(base: "https://api.example.com")  // top level
```

You don’t necessarily need to make it a singleton, but don’t just instantiate `Service` willy-nilly. Make sure there’s one instance that all the interested parties share. Much of the benefit of Siesta comes from the fact that all code using the same RESTful resource is working with the same object, and receives the same notifications. That happens within the context of one `Service` instance.

Although it’s not strictly necessary, it can be pleasant to subclass `Service` to add convenience accessors for commonly used resources:

```swift
class MyAPI: Service {
  init() {
    super.init(base: "https://api.example.com")
  }

  var profile: Resource { return resource("/profile") }
  var items:   Resource { return resource("/items") }

  func item(id: String) -> Resource {
    return items.child(id)
  }
}

let myAPI = MyAPI()
```

Note the use of computed properties instead of read-only (`let`) properties. This lets the service discard resources not currently in use if memory gets low — which brings us to…

## Getting Resources

A [`Resource`](http://bustoutsolutions.github.io/siesta/api/Classes/Resource.html) is a local cache of a RESTful resource. It holds a representation of the the resource’s data, plus information about the status of network requests related to it.

Retrieve resources from a service by providing paths relative to the service’s base URL:

```swift
myAPI.resource("/profile")
myAPI.resource("/items/123")
```

The leading slashes are optional, but help clarify.

You can navigate from a resource to a related resources:

```swift
// The following all return the same resource:

myAPI.resource("/items/123/detail")
myAPI.resource("/items").child("123").child("detail")
myAPI.resource("/items").child("123/detail")

myAPI.resource("/items").relative("./123/detail")
myAPI.resource("/items/456").relative("../123/detail")
myAPI.resource("/doodads").relative("/items/123/detail")
```

For more details, see the documentation for [`child(_:)`](http://bustoutsolutions.github.io/siesta/api/Classes/Resource.html#/s:FC6Siesta8Resource5childFS0_FSSS0_) and [`relative(_:)`](http://bustoutsolutions.github.io/siesta/api/Classes/Resource.html#/s:FC6Siesta8Resource8relativeFS0_FSSS0_), and the [related specs](https://bustoutsolutions.github.io/siesta/specs/#ResourcePathsSpec).

## The Golden Rule of Resources

> Within the context of a `Service` instance, at any given time there is at most one `Resource` object for a given URL.

This is true no matter how you navigate to a resource, no matter whether you retain it or re-request it, no matter what — just as long as the resource came (directly or indirectly) from the same `Service` instance.

Note that the rule is “at _most_ one.” If memory is low and no code references a particular resource, a service may choose to discard it and recreate it later if needed. This is transparent to client code; as long as you retain a reference to a resource, you will always keep getting only that reference. However, it does mean that resource objects are ephemeral, created and recreated on demand.