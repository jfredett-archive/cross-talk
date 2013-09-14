# Cross::Talk [![Gem Version](https://badge.fury.io/rb/cross-talk.png)](http://badge.fury.io/rb/cross-talk) [![Build Status](https://travis-ci.org/jfredett/cross-talk.png?branch=master)](http://travis-ci.org/jfredett/cross-talk) [![Code Climate](https://codeclimate.com/github/jfredett/cross-talk.png)](https://codeclimate.com/github/jfredett/cross-talk) [![Coverage Status](https://coveralls.io/repos/jfredett/cross-talk/badge.png?branch=master)](https://coveralls.io/r/jfredett/cross-talk)


** THIS PROJECT IS NOT FOR USE **

It's suffered some bitrot and needs some love, I'll get back to it, I have some
ideas about how to make useful things with it, but I want to re-write it from
the ground up. It originally started as a random experiment. A harebraned idea
for a way to have a little pubsub machine in ruby, with no muss or fuss. 300
lines later it did that, but not in a way that was easy to maintain against the
ever evolving Celluloid.

It'll be back, and it'll be even better.


## Installation

Add this line to your application's Gemfile:

    gem 'cross-talk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cross-talk

## Usage

For any object (not just Celluloid Actors, though they'll work the best) simply
include `Cross::Talk` and enjoy the following features for that class:

1. Any public method will automatically send out two events -- one at the
   beginning of execution, the other at the end. These are identified by the
   schema: `<class>#<method>:<time>`. Eg. for a class `Foo`, and a method `bar`,
   calling `Foo.new.bar` would send an event `Foo#bar:before`, and then a
   `Foo#bar:after`. Note that the event is the same for any instance of the
   class, then read the "Plans" section, item 2.

2. Any Cross::Talk class can bind to an event by using the `listen` macro at
   define-time

3. Any instance of a Cross::Talk class can bind to an event later, without
   forcing every other instance to also bind to that event. Think of the
   difference between `define_method` and `define_singleton_method` (in fact
   they are implemented precisely that way)

4. Celluloid Actors which include `Cross::Talk` will have the events sent to
   them asynchronously, so the event handler won't block while trying to
   dispatch those events


## Plans

1. Improve the `listen` macro so you don't always need to supply an argument --
   it should just be ignored if it's not there.

2. Allow `listen` to bind to a specific _instance_ of an event, rather than just
   the whole class of events.

3. Refactor the codebase, it's a bit sprawling right now

4. Optimize for dispatch speed -- basically make it as lightweight as possible

5. Make the Event Dispatcher maybe use some thread primitives during dispatch
   around non-actors, so that we can join at the end and still send them
   asynchronous events?

### Pipe dreams

1. Optionally back the event manager with a message queue, because why the hell
   not? It's worth a try, maybe it'll do something neat.

2. Experiment with making this usable efficiently over DCell. Including making
   the Event Manager run as a cluster of actors, notifying remote actors, etc.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
