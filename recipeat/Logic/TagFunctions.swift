//
//  TagFunctions.swift
//  recipeat
//
//  Created by Christopher Guirguis on 5/6/20.
//  Copyright © 2020 Christopher Guirguis. All rights reserved.
//

import Foundation


enum FoodCategoricalTags:String, CaseIterable{

case american = "american"
case appetizerAndSnack = "appetizerandsnack"
case arabic = "arabic"
case bbq = "bbq"
case beef = "beef"
case bread = "bread"
case breakfast = "breakfast"
case brunch = "brunch"
case bulking = "bulking"
case cake = "cake"
case carnivore = "carnivore"
case cheesecake = "cheesecake"
case chicken = "chicken"
case chinese = "chinese"
case chocolate = "chocolate"
case christmas = "christmas"
case coffee = "coffee"
case cookie = "cookie"
case cupcake = "cupcake"
case desserts = "desserts"
case diabetic = "diabetic"
case drinks = "drinks"
case espresso = "espresso"
case esselstyn = "esselstyn"
case ethiopian = "ethiopian"
case fatFree = "fatfree"
case fish = "fish"
case french = "french"
case glutenFree = "glutenfree"
case healthy = "healthy"
case indian = "indian"
case indulgent = "indulgent"
case instantPot = "instantpot"
case italian = "italian"
case japanese = "japanese"
case ketogenic = "ketogenic"
case kids = "kids"
case korean = "korean"
case lamb = "lamb"
case latte = "latte"
case lowCalorie = "lowcalorie"
case lowCarb = "lowCarb"
case lowCholesterol = "lowcholesterol"
case lowFat = "lowFat"
case lunch = "lunch"
case mediterranean = "mediterranean"
case mexican = "mexican"
case middleEastern = "middleeastern"
case milkshake = "milkshake"
case noDairy = "nodairy"
case noEgg = "noegg"
case noNuts = "nonuts"
case noSugar = "nosugar"
case paleo = "paleo"
case pasta = "pasta"
case potatoes = "potatoes"
case pork = "pork"
case protein = "protein"
case quickAndEasy = "quickandeasy"
case salmon = "salmon"
case seafood = "seafood"
case seitan = "seitan"
case shrimp = "shrimp"
case slowCooker = "slowcooker"
case smoothies = "smoothies"
case soup = "soup"
case southern = "southern"
case spanish = "spanish"
case steak = "steak"
case stew = "stew"
case texmex = "texmex"
case thai = "thai"
case tofu = "tofu"
case vanilla = "vanilla"
case vegetarian = "vegetarian"
case vegan = "vegan"
}

var FoodTagDictionary:[FoodCategoricalTags:TagEntity]{
    let returnVal:[FoodCategoricalTags:TagEntity] = [
        
        FoodCategoricalTags.american:TagEntity(keywords: [
            "burger","pizza","hot-dog","hotdog","hot dog", "cheese burger", "cheeseburger", "fries", "barbecue", "bbq", "apple pie", "mac and cheese", "mac & cheese","chicago","new york", "newyork","pancake","waffles"
        ], dbVal: FoodCategoricalTags.american.rawValue, displayVal: "American"),

        FoodCategoricalTags.appetizerAndSnack:TagEntity(keywords: [
            "pinwheel","quiche","pigs","pig","in a blanket","dip","buffalo","buffalo dip","smokie","salsa","queso","antipasti","mini","pretzel","spread","bite","bites","slider","shrimp","sliders","skewer","deviled","bruschetta","guacamole","hummus","poppers","egg roll","egg rolls","popper"
        ], dbVal: FoodCategoricalTags.appetizerAndSnack.rawValue, displayVal: "Appetizers & Snacks"),
        
        FoodCategoricalTags.arabic:TagEntity(keywords: [], dbVal: FoodCategoricalTags.arabic.rawValue, displayVal: "Arabic"),
        FoodCategoricalTags.bbq:TagEntity(keywords: [], dbVal: FoodCategoricalTags.bbq.rawValue, displayVal: "BBQ"),
        FoodCategoricalTags.beef:TagEntity(keywords: [], dbVal: FoodCategoricalTags.beef.rawValue, displayVal: "Beef"),
        FoodCategoricalTags.bread:TagEntity(keywords: [], dbVal: FoodCategoricalTags.bread.rawValue, displayVal: "Bread"),
        FoodCategoricalTags.breakfast:TagEntity(keywords: [], dbVal: FoodCategoricalTags.breakfast.rawValue, displayVal: "Breakfast"),
        FoodCategoricalTags.brunch:TagEntity(keywords: [], dbVal: FoodCategoricalTags.brunch.rawValue, displayVal: "Brunch"),
        FoodCategoricalTags.bulking:TagEntity(keywords: [], dbVal: FoodCategoricalTags.bulking.rawValue, displayVal: "Bulking"),
        FoodCategoricalTags.cake:TagEntity(keywords: [], dbVal: FoodCategoricalTags.cake.rawValue, displayVal: "Cake"),
        FoodCategoricalTags.carnivore:TagEntity(keywords: [], dbVal: FoodCategoricalTags.carnivore.rawValue, displayVal: "Carnivore"),
        FoodCategoricalTags.cheesecake:TagEntity(keywords: [], dbVal: FoodCategoricalTags.cheesecake.rawValue, displayVal: "Cheesecake"),
        FoodCategoricalTags.chicken:TagEntity(keywords: [], dbVal: FoodCategoricalTags.chicken.rawValue, displayVal: "Chicken"),
        FoodCategoricalTags.chinese:TagEntity(keywords: [], dbVal: FoodCategoricalTags.chinese.rawValue, displayVal: "Chinese"),
        FoodCategoricalTags.chocolate:TagEntity(keywords: [], dbVal: FoodCategoricalTags.chocolate.rawValue, displayVal: "Chocolate"),
        FoodCategoricalTags.christmas:TagEntity(keywords: [], dbVal: FoodCategoricalTags.christmas.rawValue, displayVal: "Christmas"),
        FoodCategoricalTags.coffee:TagEntity(keywords: [], dbVal: FoodCategoricalTags.coffee.rawValue, displayVal: "Coffee"),
        FoodCategoricalTags.cookie:TagEntity(keywords: [], dbVal: FoodCategoricalTags.cookie.rawValue, displayVal: "Cookie"),
        FoodCategoricalTags.cupcake:TagEntity(keywords: [], dbVal: FoodCategoricalTags.cupcake.rawValue, displayVal: "Cupcake"),
        FoodCategoricalTags.desserts:TagEntity(keywords: [], dbVal: FoodCategoricalTags.desserts.rawValue, displayVal: "Desserts"),
        FoodCategoricalTags.diabetic:TagEntity(keywords: [], dbVal: FoodCategoricalTags.diabetic.rawValue, displayVal: "Diabetic"),
        FoodCategoricalTags.drinks:TagEntity(keywords: [], dbVal: FoodCategoricalTags.drinks.rawValue, displayVal: "Drinks"),
        FoodCategoricalTags.espresso:TagEntity(keywords: [], dbVal: FoodCategoricalTags.espresso.rawValue, displayVal: "Espresso"),
        FoodCategoricalTags.esselstyn:TagEntity(keywords: [], dbVal: FoodCategoricalTags.esselstyn.rawValue, displayVal: "Esselstyn"),
        FoodCategoricalTags.ethiopian:TagEntity(keywords: [], dbVal: FoodCategoricalTags.ethiopian.rawValue, displayVal: "Ethiopian"),
        FoodCategoricalTags.fatFree:TagEntity(keywords: [], dbVal: FoodCategoricalTags.fatFree.rawValue, displayVal: "Fat-Free"),
        FoodCategoricalTags.fish:TagEntity(keywords: [], dbVal: FoodCategoricalTags.fish.rawValue, displayVal: "Fish"),
        FoodCategoricalTags.french:TagEntity(keywords: [], dbVal: FoodCategoricalTags.french.rawValue, displayVal: "French"),
        FoodCategoricalTags.glutenFree:TagEntity(keywords: [], dbVal: FoodCategoricalTags.glutenFree.rawValue, displayVal: "Gluten-Free"),
        FoodCategoricalTags.healthy:TagEntity(keywords: [], dbVal: FoodCategoricalTags.healthy.rawValue, displayVal: "Healthy"),
        FoodCategoricalTags.indian:TagEntity(keywords: [], dbVal: FoodCategoricalTags.indian.rawValue, displayVal: "Indian"),
        FoodCategoricalTags.indulgent:TagEntity(keywords: [], dbVal: FoodCategoricalTags.indulgent.rawValue, displayVal: "Indulgent"),
        FoodCategoricalTags.instantPot:TagEntity(keywords: [], dbVal: FoodCategoricalTags.instantPot.rawValue, displayVal: "Instant Pot"),
        FoodCategoricalTags.italian:TagEntity(keywords: [], dbVal: FoodCategoricalTags.italian.rawValue, displayVal: "Italian"),
        FoodCategoricalTags.japanese:TagEntity(keywords: [], dbVal: FoodCategoricalTags.japanese.rawValue, displayVal: "Japanese"),
        FoodCategoricalTags.ketogenic:TagEntity(keywords: [], dbVal: FoodCategoricalTags.ketogenic.rawValue, displayVal: "Keto"),
        FoodCategoricalTags.kids:TagEntity(keywords: [], dbVal: FoodCategoricalTags.kids.rawValue, displayVal: "Great For Kids"),
        FoodCategoricalTags.korean:TagEntity(keywords: [], dbVal: FoodCategoricalTags.korean.rawValue, displayVal: "Korean"),
        FoodCategoricalTags.lamb:TagEntity(keywords: [], dbVal: FoodCategoricalTags.lamb.rawValue, displayVal: "Lamb"),
        FoodCategoricalTags.latte:TagEntity(keywords: [], dbVal: FoodCategoricalTags.latte.rawValue, displayVal: "Latte"),
        FoodCategoricalTags.lowCalorie:TagEntity(keywords: [], dbVal: FoodCategoricalTags.lowCalorie.rawValue, displayVal: "Low-Calorie"),
        FoodCategoricalTags.lowCarb:TagEntity(keywords: [], dbVal: FoodCategoricalTags.lowCarb.rawValue, displayVal: "Low-Carb"),
        FoodCategoricalTags.lowCholesterol:TagEntity(keywords: [], dbVal: FoodCategoricalTags.lowCholesterol.rawValue, displayVal: "Low-Cholesterol"),
        FoodCategoricalTags.lowFat:TagEntity(keywords: [], dbVal: FoodCategoricalTags.lowFat.rawValue, displayVal: "Low-Fat"),
        FoodCategoricalTags.lunch:TagEntity(keywords: [], dbVal: FoodCategoricalTags.lunch.rawValue, displayVal: "Lunch"),
        FoodCategoricalTags.mexican:TagEntity(keywords: [], dbVal: FoodCategoricalTags.mexican.rawValue, displayVal: "Mexican"),
        FoodCategoricalTags.mediterranean:TagEntity(keywords: [], dbVal: FoodCategoricalTags.mediterranean.rawValue, displayVal: "Mediterranean"),
        FoodCategoricalTags.middleEastern:TagEntity(keywords: [], dbVal: FoodCategoricalTags.middleEastern.rawValue, displayVal: "Middle-Eastern"),
        FoodCategoricalTags.milkshake:TagEntity(keywords: [], dbVal: FoodCategoricalTags.milkshake.rawValue, displayVal: "Milkshake"),
        FoodCategoricalTags.noDairy:TagEntity(keywords: [], dbVal: FoodCategoricalTags.noDairy.rawValue, displayVal: "Dairy-Free"),
        FoodCategoricalTags.noEgg:TagEntity(keywords: [], dbVal: FoodCategoricalTags.noEgg.rawValue, displayVal: "No Eggs"),
        FoodCategoricalTags.noNuts:TagEntity(keywords: [], dbVal: FoodCategoricalTags.noNuts.rawValue, displayVal: "Nut-Free"),
        FoodCategoricalTags.noSugar:TagEntity(keywords: [], dbVal: FoodCategoricalTags.noSugar.rawValue, displayVal: "Sugar-Free"),
        FoodCategoricalTags.paleo:TagEntity(keywords: [], dbVal: FoodCategoricalTags.paleo.rawValue, displayVal: "Paleo"),
        FoodCategoricalTags.pasta:TagEntity(keywords: [], dbVal: FoodCategoricalTags.pasta.rawValue, displayVal: "Pasta"),
        FoodCategoricalTags.potatoes:TagEntity(keywords: [], dbVal: FoodCategoricalTags.potatoes.rawValue, displayVal: "Potatoes"),
        FoodCategoricalTags.pork:TagEntity(keywords: [], dbVal: FoodCategoricalTags.pork.rawValue, displayVal: "Pork"),
        FoodCategoricalTags.protein:TagEntity(keywords: [], dbVal: FoodCategoricalTags.protein.rawValue, displayVal: "Protein"),
        FoodCategoricalTags.quickAndEasy:TagEntity(keywords: [], dbVal: FoodCategoricalTags.quickAndEasy.rawValue, displayVal: "Quick & Easy"),
        FoodCategoricalTags.salmon:TagEntity(keywords: [], dbVal: FoodCategoricalTags.salmon.rawValue, displayVal: "Salmon"),
        FoodCategoricalTags.seafood:TagEntity(keywords: [], dbVal: FoodCategoricalTags.seafood.rawValue, displayVal: "Seafood"),
        FoodCategoricalTags.seitan:TagEntity(keywords: [], dbVal: FoodCategoricalTags.seitan.rawValue, displayVal: "Seitan"),
        FoodCategoricalTags.shrimp:TagEntity(keywords: [], dbVal: FoodCategoricalTags.shrimp.rawValue, displayVal: "Shrimp"),
        FoodCategoricalTags.slowCooker:TagEntity(keywords: [], dbVal: FoodCategoricalTags.slowCooker.rawValue, displayVal: "Slow Cooker"),
        FoodCategoricalTags.smoothies:TagEntity(keywords: [], dbVal: FoodCategoricalTags.smoothies.rawValue, displayVal: "Smoothies"),
        FoodCategoricalTags.soup:TagEntity(keywords: [], dbVal: FoodCategoricalTags.soup.rawValue, displayVal: "Soup"),
        FoodCategoricalTags.southern:TagEntity(keywords: [], dbVal: FoodCategoricalTags.southern.rawValue, displayVal: "Southern"),
        FoodCategoricalTags.spanish:TagEntity(keywords: [], dbVal: FoodCategoricalTags.spanish.rawValue, displayVal: "Spanish"),
        FoodCategoricalTags.steak:TagEntity(keywords: [], dbVal: FoodCategoricalTags.steak.rawValue, displayVal: "Steak"),
        FoodCategoricalTags.stew:TagEntity(keywords: [], dbVal: FoodCategoricalTags.stew.rawValue, displayVal: "Stew"),
        FoodCategoricalTags.texmex:TagEntity(keywords: [], dbVal: FoodCategoricalTags.texmex.rawValue, displayVal: "Tex-Mex"),
        FoodCategoricalTags.thai:TagEntity(keywords: [], dbVal: FoodCategoricalTags.thai.rawValue, displayVal: "Thai"),
        FoodCategoricalTags.tofu:TagEntity(keywords: [], dbVal: FoodCategoricalTags.tofu.rawValue, displayVal: "Tofu"),
        FoodCategoricalTags.vanilla:TagEntity(keywords: [], dbVal: FoodCategoricalTags.vanilla.rawValue, displayVal: "Vanilla"),
        FoodCategoricalTags.vegetarian:TagEntity(keywords: [], dbVal: FoodCategoricalTags.vegetarian.rawValue, displayVal: "Vegetarian"),
        FoodCategoricalTags.vegan:TagEntity(keywords: [], dbVal: FoodCategoricalTags.vegan.rawValue, displayVal: "Vegan"),
        
    ]
    return returnVal
}
