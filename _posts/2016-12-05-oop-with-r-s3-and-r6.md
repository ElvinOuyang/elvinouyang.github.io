---
title: "Object-Oriented Programming with R"
date: 2016-12-05
tags:
  - R-programming
  - Data-Camp
  - OOP
categories:
  - Study Notes
---

## 1. Introduction to OOP in R
**Difference between functional programming and OOP?**

+ Functional Programming: functions first, then object
+ OOP: data structures first, then functions (*methods*)

### 1.1. When to use OOP?

When building tools *for* data analysis, use object-oreinted programming; otherwise, use functional programming for analyzing data.

### 1.2. A taste of function vs. objects


```R
# Create these variables
a_numeric_vector <- rlnorm(50)
a_factor <- factor(
  sample(c(LETTERS[1:5], NA), 50, replace = TRUE)
)
a_data_frame <- data.frame(
  n = a_numeric_vector,
  f = a_factor
)
a_linear_model <- lm(dist ~ speed, cars)

# Call summary() on the numeric vector
summary(a_numeric_vector)

# Do the same for the other three objects
summary(a_factor)
summary(a_data_frame)
summary(a_linear_model)
```


       Min. 1st Qu.  Median    Mean 3rd Qu.    Max.
     0.1031  0.4518  0.8609  1.4180  1.5990  7.5560



<dl class=dl-horizontal>
	<dt>A</dt>
		<dd>9</dd>
	<dt>B</dt>
		<dd>10</dd>
	<dt>C</dt>
		<dd>8</dd>
	<dt>D</dt>
		<dd>7</dd>
	<dt>E</dt>
		<dd>8</dd>
	<dt>NA's</dt>
		<dd>8</dd>
</dl>




           n             f     
     Min.   :0.1031   A   : 9  
     1st Qu.:0.4518   B   :10  
     Median :0.8609   C   : 8  
     Mean   :1.4176   D   : 7  
     3rd Qu.:1.5988   E   : 8  
     Max.   :7.5557   NA's: 8  




    Call:
    lm(formula = dist ~ speed, data = cars)

    Residuals:
        Min      1Q  Median      3Q     Max
    -29.069  -9.525  -2.272   9.215  43.201

    Coefficients:
                Estimate Std. Error t value Pr(>|t|)    
    (Intercept) -17.5791     6.7584  -2.601   0.0123 *  
    speed         3.9324     0.4155   9.464 1.49e-12 ***
    ---
    Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

    Residual standard error: 15.38 on 48 degrees of freedom
    Multiple R-squared:  0.6511,	Adjusted R-squared:  0.6438
    F-statistic: 89.57 on 1 and 48 DF,  p-value: 1.49e-12



The same function *summary()* behaves differently on different types of objects, due to the underlying defined behaviors of these classes.

### 1.3. The Nine Systems

+ S3: (Most recommended) Precurse of R, mature and widely used
    + Makes functions behave differently on different classes
+ S4: Also prior to R
    + Hard to use, not recommended
    + Unless you use *Bioconductor*
+ ReferenceClasses: Has similar behaviors of other programming languages, not recommended
+ R6: More powerful than S3 (recommended)

### 1.4. How does R distinguish variables?

When using **str()** or **class()**, R returns the class of the variables.

When one need more information of the basic element type of the class (for instance, what's in a *matrix*), we use **typeof()** to determine the type of each element.

Use **mode()** and **storage.mode()** are used in older codes, but not useful anymore.

### 1.5. Assigning Classes and Implicit Classes

Use **class()** to also **assign** a class to a variable. In other words, the "class" of an object can be overwritten.

However, the underlying features of an existing class in R will continue to work, such as *length()*, *mean()*, *typeof()*.

> This is particularly useful for lists, since lists can be used to combine other variables into more complex variables. (Remember the Lego analogy: individual variables are like Lego pieces, and you can use lists to build whatever you like.)


## 2. S3 How-to

### 2.1. Function Overloading
Having different behaviors for different classes for the same function. This is enabled by **S3** package.

For the S3 package:

+ Functions are devided into two parts:
+ Generic function
    + print() and summary() are both generic fuctions
+ method function for each class
    + Use generic.class() to call the method for the class
    + The arguments for the generic functions should also be included in the method functions

**Do not use dots in variable naming convention, which will confuse the S3 classes**


```R
# To check if a function is a S3 method:
library(pryr)
print(is_s3_generic("t"))
print(is_s3_method("t.data.frame"))
print(is_s3_method("t.data.frame"))
```

    [1] TRUE
    [1] TRUE
    [1] TRUE


### 2.2. Step 1 to create a S3 function: create a generic function using *UseMethod( )*

You can create your own S3 functions. The first step is to **write the generic**. This is typically a **single line function that calls UseMethod(), passing its name as a string.**

The first argument to an S3 generic is usually called *x*, though this isn't compulsory. It is also good practice to include a *... ("ellipsis", or "dot-dot-dot") argument, in case arguments need to be passed from one method to another*.

Overall, the structure of an S3 generic looks like this.
```
an_s3_generic <- function(x, maybe = "some", other = "arguments", ...) {
  UseMethod("an_s3_generic")
}
```


```R
# Create get_n_elements
get_n_elements <- function(x, ...){
  UseMethod("get_n_elements")
}
```

### 2.3. Step 2 to create a S3 function: create methods

The generic function doesn't do anything; it is simply a bucket that contains multiple method, each dealing with different class object.

The **methods** are actually regular functions with two conditions:

+ The name of the method must be of the form *generic.class*.
+ The method signature - that is, the arguments that are passed in to the method - must *contain the signature of the generic*.

The syntax should look like:
```
generic.class <- function(some, arguments, ...) {
  #Do something
}
```


```R
# View get_n_elements
print(get_n_elements)

# Create a data.frame method for get_n_elements
get_n_elements.data.frame <- function(x, ...){
  nrow(x)*ncol(x)
}


# Call the method on the sleep dataset
n_elements_cars <- get_n_elements.data.frame(cars)

# View the result
print(n_elements_cars)
```

    function(x, ...){
      UseMethod("get_n_elements")
    }
    [1] 100


### 2.4. Step 3 to create a S3 function: create default method

Create a default method to deal with classes without a specific method. It is similar to creating a S3 method function with the condition that the name of the default method should always be **generic.default**.


```R
# View pre-defined objects
ls.str()

# Create a default method for get_n_elements
get_n_elements.default <- function(x, ...){
  length(unlist(x))
}

# Call the method on an array
print(get_n_elements.default(1:20))
```


    a_data_frame : 'data.frame':	50 obs. of  2 variables:
     $ n: num  0.536 0.303 1.774 1.12 4.316 ...
     $ f: Factor w/ 5 levels "A","B","C","D",..: 1 3 5 4 3 1 4 2 3 NA ...
    a_factor :  Factor w/ 5 levels "A","B","C","D",..: 1 3 5 4 3 1 4 2 3 NA ...
    a_linear_model : List of 12
     $ coefficients : Named num [1:2] -17.58 3.93
     $ residuals    : Named num [1:50] 3.85 11.85 -5.95 12.05 2.12 ...
     $ effects      : Named num [1:50] -303.914 145.552 -8.115 9.885 0.194 ...
     $ rank         : int 2
     $ fitted.values: Named num [1:50] -1.85 -1.85 9.95 9.95 13.88 ...
     $ assign       : int [1:2] 0 1
     $ qr           :List of 5
     $ df.residual  : int 48
     $ xlevels      : Named list()
     $ call         : language lm(formula = dist ~ speed, data = cars)
     $ terms        :Classes 'terms', 'formula'  language dist ~ speed
     $ model        :'data.frame':	50 obs. of  2 variables:
    a_numeric_vector :  num [1:50] 0.536 0.303 1.774 1.12 4.316 ...
    env : <environment: 0x19799d0>
    env2 : <environment: 0x19799d0>
    get_n_elements : function (x, ...)  
    get_n_elements.data.frame : function (x, ...)  
    lst : List of 2
     $ perfect: num [1:3] 6 28 496
     $ bases  : chr [1:4] "A" "C" "G" "U"
    lst2 : List of 2
     $ perfect: num [1:3] 6 28 496
     $ bases  : chr [1:4] "A" "C" "G" "T"
    n_elements_cars :  int 100


    [1] 20


### 2.5. Methodical Thinking

To check the available methods of a function, call **methods('function_name')** or **methods(function_name)**.

To check the available method of a function for a given class of object, call **methods(class = 'class_name')** or **methods(class = class_name)**.

**methods( )** returns both *S3* and *S4* methods. To find only the *S3* methods, use **.S3methods( )**, and **.S4methods( )** for *S4* methods.


```R
print(methods('print'))
```

      [1] print.acf*                                        
      [2] print.AES*                                        
      [3] print.anova*                                      
      [4] print.aov*                                        
      [5] print.aovlist*                                    
      [6] print.ar*                                         
      [7] print.Arima*                                      
      [8] print.arima0*                                     
      [9] print.AsIs                                        
     [10] print.aspell*                                     
     [11] print.aspell_inspect_context*                     
     [12] print.bibentry*                                   
     [13] print.Bibtex*                                     
     [14] print.browseVignettes*                            
     [15] print.by                                          
     [16] print.bytes*                                      
     [17] print.changedFiles*                               
     [18] print.check_code_usage_in_package*                
     [19] print.check_compiled_code*                        
     [20] print.check_demo_index*                           
     [21] print.check_depdef*                               
     [22] print.check_details*                              
     [23] print.check_doi_db*                               
     [24] print.check_dotInternal*                          
     [25] print.check_make_vars*                            
     [26] print.check_nonAPI_calls*                         
     [27] print.check_package_code_assign_to_globalenv*     
     [28] print.check_package_code_attach*                  
     [29] print.check_package_code_data_into_globalenv*     
     [30] print.check_package_code_startup_functions*       
     [31] print.check_package_code_syntax*                  
     [32] print.check_package_code_unload_functions*        
     [33] print.check_package_compact_datasets*             
     [34] print.check_package_CRAN_incoming*                
     [35] print.check_package_datasets*                     
     [36] print.check_package_depends*                      
     [37] print.check_package_description*                  
     [38] print.check_package_description_encoding*         
     [39] print.check_package_license*                      
     [40] print.check_packages_in_dir*                      
     [41] print.check_packages_in_dir_changes*              
     [42] print.check_packages_used*                        
     [43] print.check_po_files*                             
     [44] print.check_Rd_contents*                          
     [45] print.check_Rd_line_widths*                       
     [46] print.check_Rd_metadata*                          
     [47] print.check_Rd_xrefs*                             
     [48] print.check_so_symbols*                           
     [49] print.check_T_and_F*                              
     [50] print.check_url_db*                               
     [51] print.check_vignette_index*                       
     [52] print.checkDocFiles*                              
     [53] print.checkDocStyle*                              
     [54] print.checkFF*                                    
     [55] print.checkRd*                                    
     [56] print.checkReplaceFuns*                           
     [57] print.checkS3methods*                             
     [58] print.checkTnF*                                   
     [59] print.checkVignettes*                             
     [60] print.citation*                                   
     [61] print.codoc*                                      
     [62] print.codocClasses*                               
     [63] print.codocData*                                  
     [64] print.colorConverter*                             
     [65] print.compactPDF*                                 
     [66] print.condition                                   
     [67] print.connection                                  
     [68] print.CRAN_package_reverse_dependencies_and_views*
     [69] print.crayon*                                     
     [70] print.data.frame                                  
     [71] print.Date                                        
     [72] print.default                                     
     [73] print.dendrogram*                                 
     [74] print.density*                                    
     [75] print.difftime                                    
     [76] print.dist*                                       
     [77] print.Dlist                                       
     [78] print.DLLInfo                                     
     [79] print.DLLInfoList                                 
     [80] print.DLLRegisteredRoutines                       
     [81] print.dummy_coef*                                 
     [82] print.dummy_coef_list*                            
     [83] print.ecdf*                                       
     [84] print.envlist*                                    
     [85] print.factanal*                                   
     [86] print.factor                                      
     [87] print.family*                                     
     [88] print.fileSnapshot*                               
     [89] print.findLineNumResult*                          
     [90] print.formula*                                    
     [91] print.fseq*                                       
     [92] print.ftable*                                     
     [93] print.function                                    
     [94] print.getAnywhere*                                
     [95] print.glm*                                        
     [96] print.hclust*                                     
     [97] print.help_files_with_topic*                      
     [98] print.hexmode                                     
     [99] print.HoltWinters*                                
    [100] print.hsearch*                                    
    [101] print.hsearch_db*                                 
    [102] print.htest*                                      
    [103] print.infl*                                       
    [104] print.inspect*                                    
    [105] print.inspect_NILSXP*                             
    [106] print.integrate*                                  
    [107] print.isoreg*                                     
    [108] print.json*                                       
    [109] print.kmeans*                                     
    [110] print.Latex*                                      
    [111] print.LaTeX*                                      
    [112] print.libraryIQR                                  
    [113] print.listof                                      
    [114] print.lm*                                         
    [115] print.loadings*                                   
    [116] print.loess*                                      
    [117] print.logLik*                                     
    [118] print.ls_str*                                     
    [119] print.medpolish*                                  
    [120] print.MethodsFunction*                            
    [121] print.mtable*                                     
    [122] print.NativeRoutineList                           
    [123] print.news_db*                                    
    [124] print.nls*                                        
    [125] print.noquote                                     
    [126] print.numeric_version                             
    [127] print.object_size*                                
    [128] print.octmode                                     
    [129] print.packageDescription*                         
    [130] print.packageInfo                                 
    [131] print.packageIQR*                                 
    [132] print.packageStatus*                              
    [133] print.pairwise.htest*                             
    [134] print.PDF_Array*                                  
    [135] print.PDF_Dictionary*                             
    [136] print.pdf_doc*                                    
    [137] print.pdf_fonts*                                  
    [138] print.PDF_Indirect_Reference*                     
    [139] print.pdf_info*                                   
    [140] print.PDF_Keyword*                                
    [141] print.PDF_Name*                                   
    [142] print.PDF_Stream*                                 
    [143] print.PDF_String*                                 
    [144] print.person*                                     
    [145] print.POSIXct                                     
    [146] print.POSIXlt                                     
    [147] print.power.htest*                                
    [148] print.ppr*                                        
    [149] print.prcomp*                                     
    [150] print.princomp*                                   
    [151] print.proc_time                                   
    [152] print.R6*                                         
    [153] print.R6ClassGenerator*                           
    [154] print.raster*                                     
    [155] print.Rcpp_stack_trace*                           
    [156] print.Rd*                                         
    [157] print.recordedplot*                               
    [158] print.restart                                     
    [159] print.RGBcolorConverter*                          
    [160] print.rle                                         
    [161] print.roman*                                      
    [162] print.scalar*                                     
    [163] print.sessionInfo*                                
    [164] print.simple.list                                 
    [165] print.smooth.spline*                              
    [166] print.socket*                                     
    [167] print.srcfile                                     
    [168] print.srcref                                      
    [169] print.stepfun*                                    
    [170] print.stl*                                        
    [171] print.StructTS*                                   
    [172] print.subdir_tests*                               
    [173] print.summarize_CRAN_check_status*                
    [174] print.summary.aov*                                
    [175] print.summary.aovlist*                            
    [176] print.summary.ecdf*                               
    [177] print.summary.glm*                                
    [178] print.summary.lm*                                 
    [179] print.summary.loess*                              
    [180] print.summary.manova*                             
    [181] print.summary.nls*                                
    [182] print.summary.packageStatus*                      
    [183] print.summary.ppr*                                
    [184] print.summary.prcomp*                             
    [185] print.summary.princomp*                           
    [186] print.summary.table                               
    [187] print.summaryDefault                              
    [188] print.table                                       
    [189] print.tables_aov*                                 
    [190] print.terms*                                      
    [191] print.ts*                                         
    [192] print.tskernel*                                   
    [193] print.TukeyHSD*                                   
    [194] print.tukeyline*                                  
    [195] print.tukeysmooth*                                
    [196] print.undoc*                                      
    [197] print.vignette                                    
    [198] print.warnings                                    
    [199] print.xgettext*                                   
    [200] print.xngettext*                                  
    [201] print.xtabs*                                      
    see '?methods' for accessing help and source code


### 2.6. S3 and Primitive Functions

Functions that needs faster performance are usually written in C codes. However, C codes takes longer to write and harder to debug.

Functions written in **C** codes are called **Primitive Functions**. Check primitive generics using **.S3PrimitiveGenerics** to show all the primitive S3 functions.

The primitive generic functions behave differently than the normal generic functions, in that:

+ Primitive functions will remain functional on a new class if the underlying C codes can find applicable codes to analyze the new class


```R
# Create data.frame hair
hair <- list(color=c("black","brown","blonde","ginger","grey"),
                   styles=c("afro","beehive","crew cut","mohawk","mullet"))
class(hair) <- "hairstylist"
# View the structure of hair
str(hair)

# What primitive generics are available?
print(.S3PrimitiveGenerics)

# Does length.hairstylist exist?
exists('length.hairstylist')

# What is the length of hair?
length(hair)
```

    List of 2
     $ color : chr [1:5] "black" "brown" "blonde" "ginger" ...
     $ styles: chr [1:5] "afro" "beehive" "crew cut" "mohawk" ...
     - attr(*, "class")= chr "hairstylist"
     [1] "anyNA"          "as.character"   "as.complex"     "as.double"     
     [5] "as.environment" "as.integer"     "as.logical"     "as.numeric"    
     [9] "as.raw"         "c"              "dim"            "dim<-"         
    [13] "dimnames"       "dimnames<-"     "is.array"       "is.finite"     
    [17] "is.infinite"    "is.matrix"      "is.na"          "is.nan"        
    [21] "is.numeric"     "length"         "length<-"       "levels<-"      
    [25] "names"          "names<-"        "rep"            "seq.int"       
    [29] "xtfrm"         



FALSE



2


*length()* is a primitive function, which is why it will not throw an error even when there is no method for class *"hairstylist"*.

### 2.7. Assigning more than one class to an object

Use a list and the *class()* function to assign more than one "class" to an object. The **more specific class** should always come before **more generic class**. It's good practice to keep the original class as the **final class**.

When there's a specific function to check an object's class, use it. If the class is newly created, use **inherits(object_name, "class_name")** to check if an object is of certain class.

**How to chain the methods if an object have more than one applicable class?**
Use **NextMethod()** when defining the functions, so that the method will automatically go over all existing classes an object can have.


```R
kitty <- c("Miaow!")

class(kitty) <- c("cat","mammal","character")

inherits(kitty, "cat")
inherits(kitty, "mammal")
# For existing class, both inherits and is.class()
# functions work.
inherits(kitty, "character")
is.character(kitty)

inherits(kitty, "dog")
```


TRUE



TRUE



TRUE



TRUE



FALSE


When objects have *multiple* classes, you may wish to call methods for several of these classes. This is done using **NextMethod()**.

The S3 methods now take the form:
```
an_s3_method.some_class <- function(x, ...){
  #Act on some_class, then
  NextMethod("an_s3_method")
}
```
That is, **NextMethod()** should be the last line of the method.


```R
# Define a generic function what_am_i( )
what_am_i <- function(x, ...){
    UseMethod("what_am_i")
}

# Define a cat method for function what_am_i
what_am_i.cat <- function(x, ...){
    message("I'm a cat")
    NextMethod("what_am_i")
}

# Define a mammal method for function what_am_i
what_am_i.mammal <- function(x, ...){
    message("I'm a mammal")
    NextMethod("what_am_i")
}
# Define a character method for what_am_i
what_am_i.character <- function(x, ...){
    message("I'm a character vector")
}

what_am_i(kitty)
```

    I'm a cat
    I'm a mammal
    I'm a character vector


## 3. R6 How-to

R6 enables the storage of data and object within one variable. We will use R6 following two steps as below:

+ **Step 1**: Use R6Class( ) to create a **class generator** as templates for objects. **Class generator** is also called **factories**.
    + Name of the factory should be in **UpperCamelCase**
    + Data fields are stored in **private** list
+ **Step 2**: Use factory to create new objects, by calling **new()** method from the factory


### 3.1. Creating a R6 factory (Microwave Oven)

**R6Class( )** function is used to create a *factory* for a class:

+ The first argument to R6Class() is the name of the class of the objects that are created, written in UpperCamelCase
+ Another argument is called **private** and holds the data fields of the object as **a list**, with names for each of its elements
```
thing_factory <- R6Class("Thing",
  private = list(
    ..a_field = "a value",
    ..another_field = 123
  )
)
```


```R
# Load R6 package for the programming
library(R6)
```


```R
# Define microwave_oven_factory
microwave_oven_factory <- R6Class(
  "MicrowaveOven",
  private = list(
  ..power_rating_watts = 800
  )
)
```

### 3.2. Making Objects (Microwave Ovens)

To make an object, you create a factory, then call its *new()* method. Note that you don't need to define this method; *all factories have a new() method by default*.

`a_thing <- thing_factory$new()`


```R
microwave_oven <- microwave_oven_factory$new()
```

### 3.3. Hiding Complexity with Encapsulation (i.e. public list)

**Encapsulation**:

+ Seperating the implementation of the object from the user interface
+ All details of the implementation is hiding inside the *private* element
+ All details of the user interface is stored inside the *public* element
    + These details are always functions
    + Use **private`$`element** to access private elements
    + use **self`$`element** to access public elements


Code for factories with public elements should be:

```
thing_factory <- R6Class(
  "Thing",
  private = list(
    ..a_field = "a value",
    ..another_field = 123
  ),
  public = list(
    do_something = function(x, y, z) {
      # Do something here
    }
  )
)
```


```R
# Add a cook method to the factory definition
microwave_oven_factory <- R6Class(
  "MicrowaveOven",
  private = list(
    power_rating_watts = 800
  ),
  public = list(
  cook = function(time_seconds){
    Sys.sleep(time_seconds)
    print("Your food is cooked!")
  }
  )
)

# Create microwave oven object
a_microwave_oven <- microwave_oven_factory$new()

# Call cook method for 1 second
a_microwave_oven$cook(1)
```

    [1] "Your food is cooked!"


To access elements stored in *private* list, use `private$element_name`.



```R
# Add another open_door method to the factory
# definition by working on door_is_open element
microwave_oven_factory <- R6Class(
  "MicrowaveOven",
  private = list(
    ..power_rating_watts = 800,
    ..door_is_open = FALSE
  ),
  public = list(
  cook = function(time_seconds){
    Sys.sleep(time_seconds)
    print("Your food is cooked!")},
    open_door = function(){
        private$..door_is_open = TRUE},
    close_door = function(){
        private$..door_is_open = FALSE}
  )
)
```

One **special public method** for factories is called `initialize()`, which runs automatically whenever a `.new()` method is used for the factory. The pattern for an initialize() function should be:
```
--snip--
public = list(
    initialize = function(a_field, another_field) {
      if(!missing(a_field)) {
        private$..a_field <- a_field
      }
      if(!missing(another_field)) {
        private$..another_field <- another_field
      }
    }
  )
```



```R
# Add an initialize method
microwave_oven_factory <- R6Class(
  "MicrowaveOven",
  private = list(
    ..power_rating_watts = 800,
    ..door_is_open = FALSE
  ),
  public = list(
    cook = function(time_seconds) {
      Sys.sleep(time_seconds)
      print("Your food is cooked!")
    },
    open_door = function() {
      private$..door_is_open = TRUE
    },
    close_door = function() {
      private$..door_is_open = FALSE
    },
    # Add initialize() method here
    initialize = function(power_rating_watts, door_is_open) {
      if(!missing(power_rating_watts))
      {
        private$..power_rating_watts <- power_rating_watts
      }
      if(!missing(door_is_open))
      {
        private$..door_is_open <- door_is_open
      }
    }
  )
)

# Make a microwave
a_microwave_oven <- microwave_oven_factory$new(
  power_rating_watts = 650,
  door_is_open = TRUE
)
```

### 3.4. Getting and setting (read and write) with Active Bindings

The *active* element list is to allow controlled access to the objects by users on elements in other lists.

+ For read-only access, copy the value stored in private list with a condition for missing values:
+ For read-write access, give a "value" argument in the method and tells the function to give the value (if defined) to the element

```
--snip--
active = list(
    a_field = function(){
    # read-only access
        private$..a_field
    },
    another_field = function(value){
    # read-write access
        if(missing(value)){
            private$..another_field
        } else {
        check_condition_function(value)
        private$..another_field <- value
        }
    }
)
```


```R
library(devtools)
library(assertive.numbers)
library(assertive)
```


    Attaching package: ‘assertive’

    The following objects are masked from ‘package:pryr’:

        is_s3_generic, is_s3_method




```R
# Add a binding for power rating
microwave_oven_factory <- R6Class(
  "MicrowaveOven",
  private = list(
    ..power_rating_watts = 800,
    ..power_level_watts = 800
  ),
  # Add active list containing an active binding
  active = list(
    power_level_watts = function(value) {
      if(missing(value)) {
        private$..power_level_watts
      } else {
        assert_is_a_number(value) # function from "assertive" package
        assert_all_are_in_closed_range(  # function from "assertive.numbers" package
          value, lower = 0, upper = private$..power_rating_watts
        )
        private$..power_level_watts <- value
      }
    }
  )
)

# Make a microwave
a_microwave_oven <- microwave_oven_factory$new()

# Get the power level
a_microwave_oven$power_level_watts

# Try to set the power level to "400"
# a_microwave_oven$power_level_watts <- "400"

# Try to set the power level to 1600 watts
# a_microwave_oven$power_level_watts <- 1600

# Set the power level to 400 watts
a_microwave_oven$power_level_watts <- 400
```


800


### 3.5. Propagating (Copying) functionality with Inheritance

To enable automated connection between different layers of settings for classes, factories should be able to inherit functionality from "parent class". Defining a "child class" using `inherit` argument to R6Class().

```
child_class_factory <- R6Class(
    "ChildClass",
    inherit = parent_class_factory,
    # Any additional elements for the child class
)
```


```R
# First we define a parent class MicrowaveOven
microwave_oven_factory <- R6Class(
    "MicrowaveOven",
    private = list(
        ..power_rating_watts = 800,
        ..power_level_watts = 800,
        ..door_is_open = FALSE
    ),
    public = list(
        cook = function(time_seconds){
             Sys.sleep(time_seconds)
             print("Your food is cooked!")
        },
        open_door = function(){
            private$..door_is_open = TRUE
        },
        close_door = function(){
            private$..door_is_open = FALSE
        },
        initialize = function(power_rating_watts=800, door_is_open=TRUE){
            if(!missing(power_rating_watts)){
                private$..power_rating_watts <- power_rating_watts
            }
            if(!missing(door_is_open)){
                private$..door_is_open <- door_is_open
            }
        }
    ),
    active = list(
        power_rating_watts = function(){
            private$..power_rating_watts
        },
        power_level_watts = function(value){
            if(missing(value)){
                private$..power_level_watts
            } else {
                assert_is_a_number(value)
                private$..power_level_watts <- value
            }
        }
    )
)

# Create a child class FancyMicrowaveOven that inherits from MicrowaveOven
fancy_microwave_oven_factory <- R6Class(
    "FancyMicrowaveOven",
    inherit = microwave_oven_factory,
)
```


```R
microwave_oven_factory
fancy_microwave_oven_factory

a_microwave_oven <- microwave_oven_factory$new()
a_fancy_microwave <- fancy_microwave_oven_factory$new()
```


    <MicrowaveOven> object generator
      Public:
        cook: function (time_seconds)
        open_door: function ()
        close_door: function ()
        initialize: function (power_rating_watts = 800, door_is_open = TRUE)
        clone: function (deep = FALSE)
      Active bindings:
        power_rating_watts: function ()
        power_level_watts: function (value)
      Private:
        ..power_rating_watts: 800
        ..power_level_watts: 800
        ..door_is_open: FALSE
      Parent env: <environment: R_GlobalEnv>
      Locked objects: TRUE
      Locked class: FALSE
      Portable: TRUE



    <FancyMicrowaveOven> object generator
      Inherits from: <microwave_oven_factory>
      Public:
        clone: function (deep = FALSE)
      Parent env: <environment: R_GlobalEnv>
      Locked objects: TRUE
      Locked class: FALSE
      Portable: TRUE


Using **`inherits(object_name, class_name)`** will determine if an object inherits a class.


```R
inherits(a_microwave_oven, "MicrowaveOven")
inherits(a_microwave_oven, "FancyMicrowaveOven")
inherits(a_fancy_microwave, "MicrowaveOven")
inherits(a_fancy_microwave, "FancyMicrowaveOven")
inherits(a_fancy_microwave, "R6")
inherits(a_microwave_oven, "R6")
```


TRUE



FALSE



TRUE



TRUE



TRUE



TRUE


Objects of parent and child class behave the same when using the shared methods on either class.


```R
# Get power rating for each microwave
microwave_power_rating <- a_microwave_oven$power_rating_watts
fancy_microwave_power_rating <- a_fancy_microwave$power_rating_watts

# Verify that these are the same
identical(microwave_power_rating, fancy_microwave_power_rating)

# Cook with each microwave
a_microwave_oven$cook(1)
a_fancy_microwave$cook(1)
```


TRUE


    [1] "Your food is cooked!"
    [1] "Your food is cooked!"


### 3.6. Embrace, extend, override
For *child classes*:

**Override**: change the functionality of certain functions


**Extend**: add brand-new functionalities to the class with *different function names*

Child classes can access **public fields in the parent class** by using **`public$field_name`** syntax

#### Sample to Extend Functionality in Child Class:


```R
# Redefine the FancyMicrowaveOven factory with extended functionality
fancy_microwave_oven_factory <- R6Class(
    "FancyMicrowaveOven",
    inherit = microwave_oven_factory,
    # Add more functionalities to public field
    public = list(
    cook_baked_potato = function(){
        self$cook(3)
    }
    )
)

# Instantiate a FancyMicrowaveOven object
a_fancy_microwave <- fancy_microwave_oven_factory$new()

# Call the extended cook_baked_potato() function
a_fancy_microwave$cook_baked_potato()
```

    [1] "Your food is cooked!"


#### Sample to Override Functionality in Child Class:


```R
# Redefine the FancyMicrowaveOven factory by overriding functionality
fancy_microwave_oven_factory <- R6Class(
    "FancyMicrowaveOven",
    inherit = microwave_oven_factory,
    # Add more functionalities to public field
    public = list(
        cook_baked_potato = function(){
            self$cook(3)
        },
        cook = function(time_seconds){
            super$cook(time_seconds)
            # Access function
            message("Enjoy your dinner!")
        }
    )
)

# Instantiate a FancyMicrowaveOven object
a_fancy_microwave <- fancy_microwave_oven_factory$new()

# Call the extended cook_baked_potato() function
a_fancy_microwave$cook(1)
```

    [1] "Your food is cooked!"


    Enjoy your dinner!


### 3.7. Multiple levels of inheritance

In a scenario where more than one level of inheritance happens, each child level can only use `super$` to access the **direct parent** of itself. Multiple `super$` access is not allowed.

To work around this limitation, the **intermediate classes** should expose their parents through **active binding**, using name `super_` and should simply return `super`.

```
--snip--
active = list(
  super_ = function() super
)
```


```R
# Adjust the fancy_microwave_oven_factory to expose parent functionality
fancy_microwave_oven_factory <- R6Class(
    "FancyMicrowaveOven",
    inherit = microwave_oven_factory,
    # Add more functionalities to public field
    public = list(
        cook_baked_potato = function(){
            self$cook(3)
        },
        cook = function(time_seconds){
            super$cook(time_seconds)
            # Access function
            message("Enjoy your dinner!")
        }
    ),
    active = list(
    super_ = function() super
    )
)

# Instantiate a fancy microwave object
a_fancy_microwave <- fancy_microwave_oven_factory$new()

# Call the fancy microwave's super_ binding
a_fancy_microwave$super_

```


    <environment: 0x35572e8>


Once intermediate classes have exposed their parent functionality with *super_* active bindings, you can access methods across several generations of R6 class. The syntax is:

```
parent_method <- super$method()
grand_parent_method <- super$super_$method()
great_grand_parent_method <- super$super_$super_$method()
```

### 3.8. Use environments (env) to share variables

The *environment* variable type is similar to a *list* in that it can contain other variables.

You can create a new environment using `new.env()`. **However, one needs to create an empty *env* before adding variables into it**.

Variables can be added to the environment using the same syntax as for lists, that is, you can use the `$` and `[[` operators.

One can check the contents of an `env` object by using `ls.str()` function.


```R
# Define a new environment
env <- new.env()

# Add an element named perfect
env$perfect <- c(6, 28, 496)

# Add an element named bases
env[['bases']] <- c('A','C','G','T')

# Show the contents of env
ls.str(env)
```


    bases :  chr [1:4] "A" "C" "G" "T"
    perfect :  num [1:3] 6 28 496


**Change by value vs. Change by reference**:

Most types of R variable use "copy by value", meaning that when you take a copy of them, the new variable has its own copy of the values. In this case, *changing one variable does not affect the other*.

Environments use a different system, known as "copy by reference", so that *all copies are identical; changing one copy changes all the copies*.


```R
# Assign lst and env
lst <- list(
  perfect = c(6, 28, 496),
  bases = c("A", "C", "G", "T")
)
env <- list2env(lst)

# Copy lst
lst2 <- lst

# Change lst's bases element
lst$bases <- c('A','C','G','U')

# Test lst and lst2 identical
identical(lst$bases, lst2$bases)

# Copy env
env2 <- env

# Change env's bases element
env2$bases <- c('A','C','G','U')

# Test env and env2 identical
identical(env$bases, env2$bases)
```


FALSE



TRUE


R6 classes can use environments' copy by reference behavior to **share fields between objects**. To set this up, define a private field named shared. This field takes several lines to define. It should:

+ Create a new environment.
+ Assign any shared fields to that environment.
+ Return the environment.

The shared fields should be accessed via **active bindings**. These work in the same way as other active bindings that you have seen, but retrieve the fields using a `private$shared$` prefix.

```
R6Class(
  "Thing",
  private = list(
    shared = {
      e <- new.env()
      e$a_shared_field <- 123
      e
    }
  ),
  active = list(
    a_shared_field = function(value) {
      if(missing(value)) {
        private$shared$a_shared_field
      } else {
        private$shared$a_shared_field <- value
      }
    }
  )
)
```


```R
# Update MicrowaveOven class to include env elements
microwave_oven_factory <- R6Class(
    "MicrowaveOven",
    private = list(
        ..power_rating_watts = 800,
        ..power_level_watts = 800,
        ..door_is_open = FALSE,
        shared = {
            e <- new.env()
            e$safety_warning <- "Warning. Do not try to cook metal objects."
            e
        }
    ),
    public = list(
        cook = function(time_seconds){
             Sys.sleep(time_seconds)
             print("Your food is cooked!")
        },
        open_door = function(){
            private$..door_is_open = TRUE
        },
        close_door = function(){
            private$..door_is_open = FALSE
        },
        initialize = function(power_rating_watts=800, door_is_open=TRUE){
            if(!missing(power_rating_watts)){
                private$..power_rating_watts <- power_rating_watts
            }
            if(!missing(door_is_open)){
                private$..door_is_open <- door_is_open
            }
        }
    ),
    active = list(
        power_rating_watts = function(){
            private$..power_rating_watts
        },
        power_level_watts = function(value){
            if(missing(value)){
                private$..power_level_watts
            } else {
                assert_is_a_number(value)
                private$..power_level_watts <- value
            }
        },
        safety_warning = function(value){
            if(missing(value)){
                private$shared$safety_warning
            } else {
                private$shared$safety_warning <- value
            }
        }
    )
)

# Instantiate two different MicrowaveOven
a_microwave_oven <- microwave_oven_factory$new()
another_microwave_oven <- microwave_oven_factory$new()

# Change the env element in one
a_microwave_oven$safety_warning <- "Warning. If the food is too hot you may scald yourself."

# Check the env element in the other object
another_microwave_oven$safety_warning
```


'Warning. If the food is too hot you may scald yourself.'


### 3.9. Copy or clone R6Objects

R6Ojects follow the same rule for **copy by reference**. When assigned using `a_reference_copy <- an_r6_object`, the `a_reference_copy` will remain exactly the same with the `an_r6_object`.

Instead, to **copy by value**, use `a_value <- an_r6_object$clone()` to copy the values of an object.


```R
# Create a microwave oven
a_microwave_oven <- microwave_oven_factory$new()

# Copy a_microwave_oven using <-
assigned_microwave_oven <- a_microwave_oven

# Copy a_microwave_oven using clone()
cloned_microwave_oven <- a_microwave_oven$clone()

# Change a_microwave_oven's power level  
a_microwave_oven$power_level_watts <- 400

# Check a_microwave_oven & assigned_microwave_oven same
identical(a_microwave_oven$power_level_watts,
         assigned_microwave_oven$power_level_watts)

# Check a_microwave_oven & cloned_microwave_oven different
!identical(a_microwave_oven$power_level_watts,
           cloned_microwave_oven$power_level_watts)  
```


TRUE



TRUE


A **container** object is a class that also contains anther class. This is realized by using `thing_factory$new()` to create another object as a variable in the container.

When cloning (coping by object) an container object, `container_object$clone()` will only **copy by value** on the container, but keep the "thing" as a **shared object**. To copy by value both the container and the included objects, use `a_deep_copy <- an_r6_object$clone(deep = TRUE)`


```R
# Create a power_plug_factory for PowerPlug class
power_plug_factory <- R6Class(
    "PowerPlug",
    private = list(
        ..type = "American",
        ..plug_in_status = FALSE
    ),
    public = list(
        plug_in = function(){
            private$..plug_in_status = TRUE
        },
        unplug = function(){
            private$..plug_in_status = FALSE
        },
        add_adapter = function(type){
            private$..type = type
        },
        initialize = function(plug_in_status=FALSE, type="American"){
            if(!missing(plug_in_status)){
                private$..plug_in_status <- plug_in_status
            }
            if(!missing(type)){
                private$..type <- type
            }
        }
    ),
    active = list(
        plug_in_status = function(){
            private$..plug_in_status
        },
        type = function(value){
            if(missing(value)){
                private$..type
            } else {
                private$..type <- value
            }

        }
    )
)

# Update the MicrowaveOven to include PowerPlug object
microwave_oven_factory <- R6Class(
    "MicrowaveOven",
    private = list(
        ..power_rating_watts = 800,
        ..power_level_watts = 800,
        ..door_is_open = FALSE,
        ..power_plug = power_plug_factory$new(),
        shared = {
            e <- new.env()
            e$safety_warning <- "Warning. Do not try to cook metal objects."
            e
        }
    ),
    public = list(
        cook = function(time_seconds){
             Sys.sleep(time_seconds)
             print("Your food is cooked!")
        },
        open_door = function(){
            private$..door_is_open = TRUE
        },
        close_door = function(){
            private$..door_is_open = FALSE
        },
        initialize = function(power_rating_watts=800, door_is_open=TRUE){
            if(!missing(power_rating_watts)){
                private$..power_rating_watts <- power_rating_watts
            }
            if(!missing(door_is_open)){
                private$..door_is_open <- door_is_open
            }
        }
    ),
    active = list(
        power_rating_watts = function(){
            private$..power_rating_watts
        },
        power_level_watts = function(value){
            if(missing(value)){
                private$..power_level_watts
            } else {
                assert_is_a_number(value)
                private$..power_level_watts <- value
            }
        },
        safety_warning = function(value){
            if(missing(value)){
                private$shared$safety_warning
            } else {
                private$shared$safety_warning <- value
            }
        },
        power_plug_status = function(){
            private$..power_plug$plug_in_status
        },
        power_plug_type = function(value){
            if(missing(value)){
                private$..power_plug$type
                } else {
                assert_is_a_string(value)
                private$..power_plug$type <- value
            }
        },
        power_plug = function(){
            private$..power_plug
        }
    )
)
```


```R
# Create a microwave oven
a_microwave_oven <- microwave_oven_factory$new()

# Look at its power plug
a_microwave_oven$power_plug_type
a_microwave_oven$power_plug
# Copy a_microwave_oven using clone(), no args
cloned_microwave_oven <- a_microwave_oven$clone()

# Copy a_microwave_oven using clone(), deep = TRUE
deep_cloned_microwave_oven <- a_microwave_oven$clone(deep=TRUE)

# Change a_microwave_oven's power plug type  
a_microwave_oven$power_plug_type <- "British"


# Check a_microwave_oven & cloned_microwave_oven same
identical(a_microwave_oven$power_plug$type, cloned_microwave_oven$power_plug$type)

# Check a_microwave_oven & deep_cloned_microwave_oven different
!identical(a_microwave_oven$power_plug$type,
deep_cloned_microwave_oven$power_plug$type)  
```


'British'



    <PowerPlug>
      Public:
        add_adapter: function (type)
        clone: function (deep = FALSE)
        initialize: function (plug_in_status = FALSE, type = "American")
        plug_in: function ()
        plug_in_status: active binding
        type: active binding
        unplug: function ()
      Private:
        ..plug_in_status: FALSE
        ..type: British



TRUE



FALSE


### 3.10. Finalize (Clean up) R6 Objects

Just as an R6 class can define a public **`initialize()`** method to run custom code when objects are created, they can also define a public **`finalize()`** method to run custom code when objects are destroyed.

`finalize()` should take no arguments. It is typically used to close connections to databases or files, or undo side-effects such as changing global `options()` or graphics `par()`ameters.

The template for the code should be as follows.

```
thing_factory <- R6Class(
  "Thing",
  public = list(
    initialize = function(x, y, z) {
      # do something
    },
    finalize = function() {
      # undo something
    }
  )
)
```

The finalize() method is called when the object is removed from memory by R's **automated garbage collector**. You can force a garbage collection by typing **`gc()`**.
