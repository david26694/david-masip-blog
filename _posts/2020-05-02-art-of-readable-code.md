---
toc: true
layout: post
categories: [markdown]
---

# The Art of Readable Code

Some time ago I read [The art of Readable Code](http://shop.oreilly.com/product/9780596802301.do). I recommend this read for every person starting a career where they have to code on a daily basis. Here's a summary of the ideas I liked the most.

### Better code

#### 1. Code should by easy to understand
* Key ideas:
  + Code should be easy to understand.
  + Code should be written to minimize the time it would take for someone else to understand it.
  + Smaller isn't always better.

I think defining a metric and push your efforts to improve it simplifies your life. In this case, the metric is the *time that it would take for someone to understand your code*. 

#### 2. Packing information into names
* Pack information into names.
* Choose specific words: get is not very specific.
* Avoid generic names like tmp, aux, retval.
* Variable names are tiny comments.
* Abbreviations: would a new teammate understand what the name means?
* Summary:
  + Use specific words.
  + Avoid generic names.
  + Attach important details.
  + Use capitalization, underscores and so on in a meaningful way.

This chapter allowed me to give more meaningful names to variables and functions.  When I define a function called `get_data` or a variable called `data` there's something in my head telling me I should improve it. I never call a variable `var` anymore.

#### 3. Names that can't be misconstructed
* Actively scrutinize names by asking: what other meanings can be interpreted?
* Summary:
  + Play devil's advocate with names.
  + When naming booleans, use words like *is* to make it clear.
  
I like the idea of putting yourself into a new teammate position and see how could they fuck up due to your bad naming.

#### 4. Aesthetics
* Use consistent layout, with patterns the reader can get used to.
* Make similar code look similar.
* Group related lines of code into blocks.
* Aligning parts of the code into “columns” can make code easy to skim through.
* If code mentions A, B, and C in one place, don’t say B, C, and A in another. Pick a meaningful order and stick with it.
* Use empty lines to break apart large blocks into logical “paragraphs.”

More aestethic code is easier to read.

#### 5. Knowing what to comment
* The purpose of commenting is to help the reader know as much as the writer did.
* Don’t comment just for the sake of commenting.
* Don’t comment bad names. Fix the names instead.
* Include director comments to understand the general idea. Imagine someone joins the team, what would you explain to her? These things have to be commented.
* Comment your constants.
* Put in the reader's shoes.
* Advertise likely pitfalls: what is surprising about the code? how it might by misused?
* Summarise blocks of code so the reader doesn't get lost in details.

I used to write comments just to write comments. If a function is called:

```get_client_ids```

Please don't add the comment 

```# This function gets the clients ids```

#### 6. Making comments precise and compact
* Comments should have high info-to-space ratio
* Illustrate comments with carefully chosen input/output examples.
* Add high-level idea of code instead of obvious details.

Providing examples is key if you want someone to use your code. I think `R` does this pretty well for package developers.

### Simplifying loops and logic

#### 7. Simplifying loops and logic
* Key idea: make control flow as natural as possible.
* Prefered orders in `if(a == b)` vs `if(a != b)`:
  + Prefer positive case first.
  + Prefer simpler case first.
  + Prefer more interesting case first (there can be conflicts with the above).
* Return early from functions if possible.
* Minimize nesting.

I think it's easier to reason about positive cases than negative (negating adds a complexity layer).

#### 8. Breaking down giant expressions
* Key idea: break down giant expressions into more digestible pieces.
* Explaining variables: use extra variables that capture subexpressions.
* Beware of "clever" chunks of code: they're often harder to read.

This is something we've all been told. Split your code into functions, etc. I particularly like the warning about clever chunks of code. If you need to think very hard to code it, it's probably going to be hard to understand.

#### 9. Variables and readability
* Sloppy use of variables issues:
  + The more variables, the harder to keep track of them: Eliminate variables that jut get in the way.
  + The bigger a variable scope, the longer you have to keep track: Make your variable visible by as few lines of code as possible.
  + The more often it changes, the harder it is to keep track of its value: Prefer write-once variables.
  
I particularly like the fact that variables shouldn't be updated a lot and that they should be in the shortest subset of code possible.
 
### Reorganizing your code

#### 10. Extracting unrelated subproblems
* Method to extract unrelated subproblems:
  + For each function/block, obtain the high-level goal of the code.
  + For each line of code, ask if it solves the high-level goal or an unrelated subproblem.
  + If enough lines solve an unrelated subproblem, extract the code in a separate function.
* Create general-purpose code: separate generic code from project-specific code.

#### 11. One task at a time
* Key idea: Code should be organized so that it's doing only one task at a time.
* List all tasks code is doing. Some of them might easily become functions or classes. Others become paragraphs in a funciton.

#### 12. Turning thoughts into code
* Process that can help you code clearly:
   + Describe code as you would to a colleague.
   + Pay attention to key words.
   + Write code to match description.
* The method is also valid for debugging (as describing the problem).

#### 13. Writing less code
* Eliminate nonessential features from product.
* Rethink requirements to solve the easiest version of the problem that still gets the job done.
* Stay familiar with standard libraries by reading their APIs.

