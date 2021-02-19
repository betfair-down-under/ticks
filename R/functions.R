#' Convert Odds to Betfair Price Ticks
#'
#' This function converts any odds value to its corresponding higher or lower Betfair tick.
#' Odds increase by 0.01 from 1.01 to 2, by 0.02 from 2.02 to 3 and so on
#' If the odds value is an existing Betfair tick it will return its own value regardless of parameter floor
#' Function returns a numeric
#'
#' argument odds: Decimal odds that you want to convert to nearest Betfair Tick
#' argument floor: Binary value to specify if you want the nearest Tick Below odds. Defaults to FALSE


bf_odds_map <- function(odds,
                        floor = FALSE) {
  # -------------------------------
  # Edge cases
  # -------------------------------
  
  if (is.na(odds)) {
    return_tick = NA
  } else if (odds < 1.01) {
    return_tick = 1.01
  } else if (odds > 1000) {
    return_tick = 1000
  } else {
    # -------------------------------
    # Create table of Betfair ticks
    # -------------------------------
    
    betfair_ticks <- c(
      seq(from = 1.01,
          to = 2,
          by = 0.01),
      seq(from = 2.02,
          to = 3,
          by = 0.02),
      seq(from = 3.05,
          to = 4,
          by = 0.05),
      seq(from = 4.1,
          to = 6,
          by = 0.1),
      seq(from = 6.2,
          to = 10,
          by = 0.2),
      seq(from = 10.5,
          to = 20,
          by = 0.5),
      seq(from = 21,
          to = 30,
          by = 1),
      seq(from = 32,
          to = 50,
          by = 2),
      seq(from = 55,
          to = 100,
          by = 5),
      seq(from = 110,
          to = 1000,
          by = 10)
    )
    
    # -------------------------------
    # Check if odds is a Betfair Tick
    # -------------------------------
    
    return_tick = betfair_ticks[betfair_ticks == odds]
    
    # -------------------------------
    # If odds is not a Betfair Tick
    # proceed to logic below
    # -------------------------------
    
    if (length(return_tick) == 0) {
      betfair_next_tick = dplyr::lead(betfair_ticks)
      odds_bucket = dplyr::if_else(odds >= betfair_ticks &
                                     odds < betfair_next_tick,
                                   TRUE,
                                   FALSE)
      betfair_ticks_mat <- matrix(c(betfair_ticks[odds_bucket],
                                    betfair_next_tick[odds_bucket],
                                    odds_bucket[odds_bucket]),
                                  nrow = 1)
      
      
      # -------------------------------
      # Return higher or lower tick
      # based on parameter floor
      # -------------------------------
      
      if (floor == FALSE) {
        return_tick = betfair_ticks_mat[1, 2]
      } else {
        return_tick = betfair_ticks_mat[1, 1]
      }
      
    }
    
  }
  
  return(return_tick)
  
}





#' Find the number of ticks between two Betfair prices
#'
#' This function takes in two odds as parameter and returns the number of ticks between them.
#' If odds_1 is lesser than odds_2 the result is negative
#' For example, the ticks between 2.00 and 1.96 is 4, and similarly the ticks between 10.5 and 11.5 is -2
#' Function returns a numeric
#'
#' arugment odds_1: Decimal odds (Does not have to be an existing Betfair Tick)
#' arugment odds_2 Decimal odds (Does not have to be an existing Betfair Tick)



bf_ticks_between <- function(odds_1, odds_2) {
  # -------------------------------
  # Convert odds input to existing
  # Betfair tick
  # -------------------------------
  
  
  bf_price_tick_1 <- bf_odds_map(odds_1, floor = TRUE)
  bf_price_tick_2 <- bf_odds_map(odds_2, floor = TRUE)
  
  # -------------------------------
  # Create table of Betfair ticks
  # -------------------------------
  
  betfair_ticks <- c(
    seq(from = 1.01,
        to = 2,
        by = 0.01),
    seq(from = 2.02,
        to = 3,
        by = 0.02),
    seq(from = 3.05,
        to = 4,
        by = 0.05),
    seq(from = 4.1,
        to = 6,
        by = 0.1),
    seq(from = 6.2,
        to = 10,
        by = 0.2),
    seq(from = 10.5,
        to = 20,
        by = 0.5),
    seq(from = 21,
        to = 30,
        by = 1),
    seq(from = 32,
        to = 50,
        by = 2),
    seq(from = 55,
        to = 100,
        by = 5),
    seq(from = 110,
        to = 1000,
        by = 10)
  )
  
  # -------------------------------
  # Create rank order for each tick
  # -------------------------------
  
  betfair_ticks_mat <- matrix(c(betfair_ticks, seq_along(betfair_ticks)),
                              nrow = NROW(betfair_ticks))
  
  # -------------------------------
  # Filtering ticks DF
  # for parameters
  # -------------------------------
  
  betfair_ticks_filtered <- 
    betfair_ticks_mat[betfair_ticks == bf_price_tick_1 | betfair_ticks == bf_price_tick_2, ]
  
  # -------------------------------
  # Calculation for ticks between
  # -------------------------------
  
  
  if(bf_price_tick_1 == bf_price_tick_2){
    ticks_between <- 0
  } else {
    
    ticks_between <- betfair_ticks_filtered[, 2] - dplyr::lag(betfair_ticks_filtered[, 2])
    ticks_between <- ticks_between[!is.na(ticks_between)]
    
    if(bf_price_tick_1 < bf_price_tick_2){
      ticks_between <- -1 * ticks_between
    }
    
  }
  
  return(ticks_between)
  
}