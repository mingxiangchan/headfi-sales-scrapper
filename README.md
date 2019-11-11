# Headfi Sales Scrapper

This project generates boxplots of the prices for items posted on [Headfi Headphones For Sale](https://www.head-fi.org/forums/headphones-for-sale-trade.6550/). 

![etymotic-graph](./generated/etymotic_er_4_sr.png)





## Usage

Setup
```bash
mix deps.get
mix deps.compile
mix ecto.reset
```

Scrap Headfi data

```
mix seed
```

Generate boxplot of prices for a particular item (fuzzy search, separate sections of the name using spaces)

```bash
mix gen_chart er 4 sr
mix gen_chart stax l 700
````

## TODOS:

1. Handle currency conversions (currently assume all prices to be USD, some are actually in Euros)


## License

MIT License

----
Created:  2019-11-08Z
