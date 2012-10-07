#Build a module
When coding the SCSS of a module consider what is repeatable and what is variable. Leave yourself room for improvement. When creating a mixin consider using arguments so that when the mixin is used you have variations available to you.

A well engineered SCSS module will allow for flexible application to the designated markup block without duplication of CSS styles. If you find yourself over-riding CSS declarations within a selector from what the mixin inserts consider using arguments or using a silent extend. 

Each Sass module folder should contain a `mixins.scss` file and a `extends.scss` file. In `sass/_modules.scss` add your created mixins and extends in the appropriate list.

##Definition of a module
A module is a self-contained series of design elements and possibly UI patterns. Regardless of fixed, fluid or responsive experience, the module itself does not have a defined space. It should always take up 100% width and it's height dictated by the content contined within. 

Every module will have an independent Sass file for UI constuction. 

##Know when you are doing it wrong
If you find yourself coding elemental and/or UI patterns within a module, this should be a smell to refactor. 

###Here is a simple example of a reusable module
```scss
@mixin information_panel($cols: 12, $grid_uom: em) {
  @include grid(12, $col_width: $cols, $grid_padding: 10, $grid_border: 1, $grid_uom: $grid_uom);
  @include standard_rounded_border;
  padding-top: em(10);
  padding-bottom: em(10);
  &:first-child {
    @include alpha;
  }
  &:last-child {
    @include omega;
  }
  h2 {
    @include panel_header;    
  }
  article {
    padding: em(20) em(10);
    border-bottom: 1px solid $delta_grey; 
    h3 {
      @include medium;
      font-weight: bold;
      margin-bottom: 1em;
    }
    &:last-child {
      border: 0;
    }
  }
  .sub_article_push {
    margin-left: em(10);
  }
}
```

##Silent extends
Silent extends are the perfect compliment to Sass mixins. Mixins are awesome, but their largest fault is that they copy all the CSS into the newly created selector. This has brought on a lot of criticism of Sass. The solution, silent extends. 

The idea beind this tool is that you can create static class from mixins and/or other CSS declarations and these new classes do not manifest themselves in the processed CSS until extended. 

####Example Sass using silent extends
```scss
%kung {
  background: green;
  color: yellow;
}

%foo {
  background: orange;
  color: red;
  font-size: 12px;
}

.foo_one {
  @extend %foo;
}

.foo_two {
  @extend %foo;
}
```

####Output CSS
```css
.foo_one, .foo_two {
  background: orange;
  color: red;
  font-size: 12px;
}
```












