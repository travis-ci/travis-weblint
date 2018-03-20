require 'bundler/setup'
require 'sinatra'
require 'travis'
require 'slim'
require 'gh'

get '/' do
  slim ""
end

get '/style.css' do
  sass :style
end

__END__

@@ layout

html
  head
    title Validate your .travis.yml file
    link rel="stylesheet" type="text/css" href="/style.css"
  body
    h1
      a href="/" Travis WebLint

    == yield

    p.tagline
      | This version of WebLint is deprecated.
      br
      br
      | We are working on a new yml parsing library, <a href="https://github.com/travis-ci/travis-yml">travis-yml</a>, which is slowly being rolled out on the Travis CI hosted platform. We are also working on a new WebLint tool.
      br
      br
      | For more information about opting in to use `travis-yml` in your Travis builds please contact <a href="mailto:support@travis-ci.com">support@travis-ci.com</a>

@@ style

// http://meyerweb.com/eric/tools/css/reset/
// v2.0 | 20110126
// License: none (public domain)

html, body, div, span, applet, object, iframe, h1, h2, h3, h4, h5, h6, p, blockquote, pre, a, abbr, acronym, address, big, cite, code, del, dfn, em, img, ins, kbd, q, s, samp, small, strike, strong, sub, sup, tt, var, b, u, i, center, dl, dt, dd, ol, ul, li, fieldset, form, label, legend, table, caption, tbody, tfoot, thead, tr, th, td, article, aside, canvas, details, embed, figure, figcaption, footer, header, hgroup, menu, nav, output, ruby, section, summary, time, mark, audio, video
  margin: 0
  padding: 0
  border: 0
  font-size: 100%
  font: inherit
  vertical-align: baseline

// HTML5 display-role reset for older browsers
article, aside, details, figcaption, figure, footer, header, hgroup, menu, nav, section
  display: block

body
  line-height: 1

ol, ul
  list-style: none

blockquote, q
  quotes: none

blockquote
  &:before, &:after
    content: ''
    content: none

q
  &:before, &:after
    content: ''
    content: none

table
  border-collapse: collapse
  border-spacing: 0

// General

body
  margin: 2em auto 2em auto
  width: 960px
  font-size: 14px
  line-height: 1.4286
  color: #555
  background: #fff
  font-family: "Helvetica Neue", Arial, Verdana, sans-serif

b
  font-weight: bold

a
  color: #36c
  outline: none
  text-decoration: underline

a:visited
  color: #666

a:hover
  color: #6c3
  text-decoration: none

h1
  color: #000
  font-size: 4em
  font-weight: bold
  line-height: 1em

h1 a:link, h1 a:visited, h1 a:hover, h1 a:active
  color: #000
  text-decoration: none

h2
  font-size: 2em
  font-weight: bold
  line-height: 2em

p.tagline
  color: #777
  display: block
  font: italic 1.25em Georgia, Times, Serif
  line-height: 1.67em
  margin: 1em 0 4em 0
  padding: 0 0 1.25em 0
  border-bottom: 1px solid #ccc

// Result

.result
  font-size: 1.5em
  margin-bottom: 2em

p.result
  color: #6c3

ul.result
  list-style: none

ul.result li:before
  content: ">"
  display: inline-block
  background-color: #c00
  color: #fff
  width: 1.4em
  height: 1.4em
  font-size: 40%
  margin-right: 1em
  text-align: center
  position: relative
  top: -0.5em

// jobs

.jobs
  font-size: 1.5em

ul.jobs
  list-style: none
  margin-bottom: 2em
  font-size: 1.25em

ul.jobs li:before
  content: ">"
  display: inline-block
  background-color: #000
  color: #fff
  width: 1.4em
  height: 1.4em
  font-size: 48%
  margin-right: 1em
  text-align: center
  position: relative
  top: -0.5em

// Form

form
  display: inline-block
  vertical-align: top
  width: 475px

form.left
  margin-right: 55px

label, input
  display: block

label
  margin-bottom: 0.5em

input, textarea
  font-size: 14px
  line-height: 1.4286
  color: #555
  font-family: "Helvetica Neue", Arial, Verdana, sans-serif
  border: 1px solid #ccc
  margin: 0

input[type=text]
  padding: 4px 8px
  width: 400px

input[type=submit]
  background: #efefef
  padding: 4px 8px
  margin-top: 0.5em

input[type=submit]:hover
  cursor: pointer

textarea
  padding: 4px 8px
  width: 460px
  height: 250px

// Various

.error
  color: #c00

.note
  margin-top: 5em

.flash-message
  display: flex
  align-items: center
  height: 38px
  padding: 0 1em
  margin: 0 0 2em
  line-height: 1
  font-size: 1.14rem

  .preamble
    font-weight: bold
    padding-right: 0.5rem

.notice
  color: #cdb62c
  background-color: #faf6d8
