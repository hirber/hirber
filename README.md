[![CircleCI](https://circleci.com/gh/hirber/hirber.svg?style=shield)](https://circleci.com/gh/hirber/hirber)

## Preface

This gem is a direct fork of [Hirb](https://github.com/cldwalker/hirb) (0.7.3)
which appears to be unmaintained since 2015. Release of Ruby (2.7.2)
introduced a breaking change into one of the methods in IRB module, which made
this Gem partially unusable. This fork aims to fix incompatibility. Feel free
to open PRs if you have any ideas to extend the functionality.

This gem works with Ruby 2.7.2 up to 3.4.1.

## Description

Hirb provides a mini view framework for console applications and uses it to
improve ripl(irb)'s default inspect output. Given an object or array of
objects, hirb renders a view based on the object's class and/or ancestry. Hirb
offers reusable views in the form of helper classes. The two main helpers,
Hirb::Helpers::Table and Hirb::Helpers::Tree, provide several options for
generating ascii tables and trees. Using Hirb::Helpers::AutoTable, hirb has
useful default views for at least ten popular database gems i.e. Rails'
ActiveRecord::Base. Other than views, hirb offers a smart pager and a console
menu. The smart pager only pages when the output exceeds the current screen
size. The menu is used in conjunction with tables to offer [two dimensional menus](http://tagaholic.me/2010/02/16/two-dimensional-console-menus-with-hirb.html).

## Install

Install the gem with:

    gem install hirber

For people using full-width unicode characters, install
[hirb-unicode](https://github.com/miaout17/hirb-unicode):

    gem install hirb-unicode

## View Tutorials

* To create and configure views, see Hirb::View or [here if on the web](http://tagaholic.me/hirb/doc/classes/Hirb/View.html).
* To create dynamic views, see Hirb::DynamicView or [here if on the web](http://tagaholic.me/hirb/doc/classes/Hirb/DynamicView.html).

## Printing Ascii Tables

To print ascii tables from an array of arrays, hashes or any objects:

    puts Hirb::Helpers::AutoTable.render(ARRAY_OF_OBJECTS)

Hirb will intelligently pick up on field names from an array of hashes and
create properly-aligned fields from an array of arrays. See
[here](http://tagaholic.me/2009/10/15/boson-and-hirb-interactions.html#hirbs_handy_tables) for examples.

## Rails Example

Let's load and enable the view framework:
    $ rails console
    Loading local environment (Rails 3.0.3)
    >> require 'hirb'
    => true
    >> Hirb.enable
    => nil

The default configuration provides table views for ActiveRecord::Base
descendants. If a class isn't configured, Hirb reverts to irb's default echo
mode.
    >> Hirb::Formatter.dynamic_config['ActiveRecord::Base']
    => {:class=>Hirb::Helpers::AutoTable, :ancestor=>true}

    # Tag is a model class and descendant of ActiveRecord::Base
    >> Tag.last
    +-----+-------------------------+-------------+---------------+-----------+-----------+-------+
    | id  | created_at              | description | name          | namespace | predicate | value |
    +-----+-------------------------+-------------+---------------+-----------+-----------+-------+
    | 907 | 2009-03-06 21:10:41 UTC |             | gem:tags=yaml | gem       | tags      | yaml  |
    +-----+-------------------------+-------------+---------------+-----------+-----------+-------+
    1 row in set

    >> Hirb::Formatter.dynamic_config['String']
    => nil
    >> 'plain ol irb'
    => 'plain ol irb'
    >> Hirb::Formatter.dynamic_config['Symbol']
    => nil
    >> :blah
    => :blah

From above you can see there are no views configured for a String or a Symbol
so Hirb defaults to irb's echo mode. On the other hand, Tag has a view thanks
to being a descendant of ActiveRecord::Base and there being an :ancestor
option.

Having seen hirb display views based on an output object's class, let's see it
handle an array of objects:

    >> Tag.all :limit=>3, :order=>"id DESC"
    +-----+-------------------------+-------------+-------------------+-----------+-----------+----------+
    | id  | created_at              | description | name              | namespace | predicate | value    |
    +-----+-------------------------+-------------+-------------------+-----------+-----------+----------+
    | 907 | 2009-03-06 21:10:41 UTC |             | gem:tags=yaml     | gem       | tags      | yaml     |
    | 906 | 2009-03-06 08:47:04 UTC |             | gem:tags=nomonkey | gem       | tags      | nomonkey |
    | 905 | 2009-03-04 00:30:10 UTC |             | article:tags=ruby | article   | tags      | ruby     |
    +-----+-------------------------+-------------+-------------------+-----------+-----------+----------+
    3 rows in set

At any time you can disable Hirb if you really like irb's lovely echo mode:
    >> Hirb.disable
    => nil
    >> Tag.all :limit=>3, :order=>"id DESC"
    => [#<Tag id: 907, name: "gem:tags=yaml", description: nil, created_at: "2009-03-06 21:10:41",
    namespace: "gem", predicate: "tags", value: "yaml">, #<Tag id: 906, name: "gem:tags=nomonkey",
    description: nil, created_at: "2009-03-06 08:47:04", namespace: "gem", predicate: "tags", value:
    "nomonkey">, #<Tag id: 905, name: "article:tags=ruby", description: nil, created_at: "2009-03-04
    00:30:10", namespace: "article", predicate: "tags", value: "ruby">]

## Views: Anytime, Anywhere

While preconfigured tables are great for database records, sometimes you just
want to create tables/views for any output object:

    #These examples don't need to have Hirb::View enabled.
    >> Hirb.disable
    => nil

    # Imports table() and view()
    >> extend Hirb::Console
    => main

    # Create a unicode table
    >> table [[:a, :b, :c]], :unicode => true
    ┌───┬───┬───┐
    │ 0 │ 1 │ 2 │
    ├───┼───┼───┤
    │ a ╎ b ╎ c │
    └───┴───┴───┘
    1 row in set

    # Creates github-markdown
    >> table [[:a, :b, :c]], :markdown => true
    | 0 | 1 | 2 |
    |---|---|---|
    | a | b | c |

    # Create a table of Dates comparing them with different formats.
    >> table [Date.today, Date.today.next_month], :fields=>[:to_s, :ld, :ajd, :amjd, :asctime]
    +------------+--------+-----------+-------+--------------------------+
    | to_s       | ld     | ajd       | amjd  | asctime                  |
    +------------+--------+-----------+-------+--------------------------+
    | 2009-03-11 | 155742 | 4909803/2 | 54901 | Wed Mar 11 00:00:00 2009 |
    | 2009-04-11 | 155773 | 4909865/2 | 54932 | Sat Apr 11 00:00:00 2009 |
    +------------+--------+-----------+-------+--------------------------+
    2 rows in set

    # Same table as the previous method. However view() will be able to call any helper.
    >> view [Date.today, Date.today.next_month], :class=>:object_table,
      :fields=>[:to_s, :ld, :ajd, :amjd, :asctime]

If these console methods weren't convenient enough, try:

    # Imports view() to all objects.
    >> require 'hirb/import_object'
    => true
    # Yields same table as above examples.
    >> [Date.today, Date.today.next_month].view :class=>:object_table,
      :fields=>[:to_s, :ld, :ajd, :amjd, :asctime]

Although views by default are printed to STDOUT, they can be easily modified
to write anywhere:
    # Setup views to write to file 'console.log'.
    >> Hirb::View.render_method = lambda {|output| File.open("console.log", 'w') {|f| f.write(output) } }

    # Writes to file with same table output as above example.
    >> view [Date.today, Date.today.next_month], :class=>:object_table,
      :fields=>[:to_s, :ld, :ajd, :amjd, :asctime]

    # Doesn't write to file because Symbol doesn't have a view and thus defaults to irb's echo mode.
    >> :blah
    => :blah

    # Go back to printing Hirb views to STDOUT.
    >> Hirb::View.reset_render_method

## Pager

Hirb has both pager and formatter functionality enabled by default. Note - if
you copy and paste into your ruby console and think that one of your lines
will kick off the pager, be aware that subsequent characters will go to your
pager and could cause side effects like saving a file.

If you want to turn off the functionality of either pager or formatter, pass
that in at startup:

    Hirb.enable :pager=>false
    Hirb.enable :formatter=>false

or toggle their state at runtime:

    Hirb::View.toggle_pager
    Hirb::View.toggle_formatter

## Sharing Helpers and Views

If you have tested helpers you'd like to share, fork Hirb and put them under
lib/hirb/helpers. To share views for certain classes, put them under
lib/hirb/views. Please submit views for gems that have a nontrivial number of
users.

## Limitations

If using Wirble and irb, you should call Hirb after it since they both
override irb's default output.

## Motivation

Table code from http://gist.github.com/72234 and [my console app's needs](http://github.com/cldwalker/tag-tree).

## Credits
*   Chrononaut for vertical table helper.
*   janlelis for unicode table helper.
*   technogeeky and FND for markdown table helper.
*   hsume2, crafterm, spastorino, xaviershay, bogdan, asanghi, vwall,
    maxmeyer, jimjh, ddoherty03, rochefort and joshua for patches.


## Bugs/Issues

Please report them [on github](http://github.com/cldwalker/hirb/issues).

## Contributing
[See here](http://tagaholic.me/contributing.html)

## Links
*   http://tagaholic.me/2009/03/13/hirb-irb-on-the-good-stuff.html
*   http://tagaholic.me/2009/03/18/ruby-class-trees-rails-plugin-trees-with-hirb.html
*   http://tagaholic.me/2009/06/19/page-irb-output-and-improve-ri-with-hirb.html

