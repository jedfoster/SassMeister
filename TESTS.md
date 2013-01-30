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


## Color Schemer ##

    $primary: cs-primary();
    $secondary: darken(cs-secondary(), 10%); // too light, darkening this up a bit.
    $tertiary: cs-tertiary();
    $quadrary: cs-quadrary();

    .primary {
      color: $primary
    }

    .secondary {
      color: $secondary
    }

    .tertiary {
      color: $tertiary
    }

    .quadrary {
      color: $quadrary
    }


## Compass ##

    #wrapper {
      @include columns(20em 2);
    }


## Compass Slideshow ##

    .slideshow {
      @include slideshow;
    }


## Fancy Buttons ##

    button {
      @include fancy-button-structure(26px, 1em, 4px);
      @include fancy-button-colors(#124c89, adjust-hue(#124c89, -120), darken(adjust-hue(#124c89, -120), 6));
    }


## Fittext ##

    h1 {
      font-size: 6em; // For browsers that don't support media queries.
      @include fittext($min-media: 200px, $max-media: 1400px, $min-font-size: 5em, $max-font-size: 50em, $media-increment: 100, $font-increment: 1.5, $ratio: 1, $round: false);
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


## Modular Scale ##

    .lace {
      width: ms(7, 16px, golden() fourth() );
    }


## Neat ##

    section {
      @include outer-container;
      aside { @include span-columns(3); }
      article { @include span-columns(9); }
    }


## Responsive Calculator ##

    .foo {
      margin: rwdcalc(10 10px 13 1em, 960);
    }


## Responsive Sass ##

    .block {
      @include mobile-landscape(960, 240, "/images/high-res.png");
    }


## Salsa ##

    // Nested grids AG test
    .e1 { @include grid(2); }
    .e2 { @include grid(6 container); }
    .e3 { @include grid(2); }
    .e4 { @include grid(3/6); }
    .e5 { @include grid(3/6); }
    .e6 { @include grid(2/6); }
    .e7 { @include grid(4/6 container); }
    .e8 { @include grid(2/4); }
    .e9 { @include grid(2/4); }
    .e10 { @include grid(100%); }



## Sassy Buttons ##

    .red { @include sassy-button-gradient("matte", #e86a43); }

    .blue { @include sassy-button-gradient("simple", #4d8ccd); }

    .green { @include sassy-button-gradient("glass", #8cbe5f); }


## Sassy Math ##

    $fraction: 2.5;

    $fraction-2: to-fraction(2.5);

    #tester {
      numerator: numerator($fraction);
      denominator: denominator($fraction);
      to-fraction: to-fraction($fraction);
      to-decimal: to-decimal(3/2);
      exponent: exponent(8, 2, 3);
      power: power(20, pi());
      sqrt: sqrt(16129);
      nth-root: nth-root(27, 3);
      factorial: factorial(9);
      pi: pi();
      e: e();
      ln: ln(e());
      log10: log10(10);
      golden: golden-ratio();
      is-int: is-int(4);
      is-float: is-float(2);
    }


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


## Toolkit ##

    .ratio-16-9 {
      @include intrinsic-ratio;
    }

    .ratio-4-3-75 {
      @include intrinsic-ratio(4/3, 75%);
    }

    .ratio-7-8-75-iframe-no-extend {
      @include intrinsic-ratio(7/8, 75%, 'iframe', false);
    }
    
## Zen Grids ##

    .content {
      @include zen-grid-item(4, 3); // Make this grid item span 4 columns. // Position this grid item in the 3rd column.
    }

    .aside2 {
      @include zen-grid-item(1, 7);
    }

    .footer1 {
      @include zen-clear(); // Apply this mixin to start a new row.
      @include zen-grid-item(3, 5);
    }
    .footer2 {
      @include zen-grid-item(4, 1);
    }