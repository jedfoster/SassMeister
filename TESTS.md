# SassMeister Tests #

Each block of SCSS should return valid CSS with no warnings or errors when tested against it's respective extension.


## Bourbon ##

    box:hover {
      @include animation-name(scale, slide);
      @include animation-duration(2s);
      @include animation-timing-function(ease);
      @include animation-iteration-count(infinite);

      // Animation shorthand works the same as the CSS3 animation shorthand
      @include animation(scale 1.0s ease-in, slide 2.0s ease);
    }


## Breakpoint ##

    // create $breakpoint variables like so
    // assume min-width (by default) if only a number
    $breakpoint-medium-width: 500px;
    $breakpoint-medium-width-em: 30em;

    .foo {
      @include breakpoint($breakpoint-medium-width) {
        content: 'medium widths';
      }
    }
    .bar {
      @include breakpoint($breakpoint-medium-width-em) {
        content: 'medium widths measured in ems';
      }
    }

    // You can use breakpoint without variables too.
    .rhcp {
      @include breakpoint(30em 40em) {
        content: 'between 30 and 40ems';
      }
    }


## Compass ##

    #wrapper {
      @include columns(20em 2);
    }


## Neat ##

    section {
      @include outer-container;
      aside { @include span-columns(3); }
      article { @include span-columns(9); }
    }


## Harsh ##

    .random {
      @include harsh();
    }

    .background-color {
      @include harsh(white, rgb(200,50,50), .95);
    }

    .bright {
      @include harsh(random, white, .05);
    }

    .dull {
      @include harsh($transparency: .95);
    }

    .specify-colors {
      @include harsh(#FF0000 blue rgb(50,200,50));
    }

    .horizontal {
      @include harsh($angle: top);
    }

    .angled {
      @include harsh($angle: -32deg);
    }


## Sassy Buttons ##

    .red { @include sassy-button-gradient("matte", #e86a43); }

    .blue { @include sassy-button-gradient("simple", #4d8ccd); }

    .green { @include sassy-button-gradient("glass", #8cbe5f); }


## Singularity.gs ##

    $grids: 3, (3, 5, 7, 5) 500px, ratio(1.75, 7) 900px;
    $grids-mobile-first: true;
    $gutters: .25, .3, .4;
    $paddings: 0, .5em;

    #bar {
      @include grid-span(2, 2);

      @include breakpoint(500px) {
        @include grid-span(2, 3);
      }

      @include breakpoint(900px) {
        @include grid-span(4, 1);
      }
    }


## Stipe ##

    .form_control {
      @include grid(4);

      &:last-child {
       @include grid(4.125, omega);
      }
      &:first-child {
        @include grid(4.125, alpha);
      }

      & button[type=submit] {
        display:block;
        margin: 1.2em auto;
      }
    }


## Susy ##

    .ag1 { @include span-columns(2,10); }
    .ag2 { @include span-columns(6,10); }
    .ag3 { @include span-columns(2 omega, 10); }
    .ag4 { @include span-columns(3,6); }
    .ag5 { @include span-columns(3 omega,6); }
    .ag6 { @include span-columns(2,6); }
    .ag7 { @include span-columns(4 omega,6); }
    .ag8 { @include span-columns(2,4); }
    .ag9 { @include span-columns(2 omega,4); }
    .ag10 { clear: both; }
