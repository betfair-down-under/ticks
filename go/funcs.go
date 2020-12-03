package bfprices

// Tick shifts the price by a number of ticks
// 	ie 	(1.01, 5) == 1.06
// 		(2.10, -12) == 1.93
func Tick(p float64, n int) float64 {
	return IndexTick(TickIndex(p) + n)
}

// TicksApart takes in two prices and returns how many ticks apart they are
// 	ie	(1.01, 1.06) == 5
// 		(2.10, 1.93) == 12
func TicksApart(p1, p2 float64) int {
	if p1 == p2 {
		return 0
	} else if p1 > p2 {
		p1, p2 = p2, p1
	}

	return TickIndex(p2) - TickIndex(p1)
}

// RoundSize rounds a volume to a valid currency value
// 	ie	10.9274 == 10.93
func RoundSize(val float64) float64 {
	return float64(int64(val*100+0.5)) / 100
}

// RoundTick rounds a price to the nearest valid tick
//  ie 1.0104 == 1.01
//     1.0532 == 1.05
//     3.57 == 3.55
//     214 == 210
func RoundTick(price float64) float64 {
	rnd, _, _ := TickVal(price)
	return rnd
}

// PriceRange returns the tick-size range the price falls in
//  ie 1.0104 == 0.01
//     1.0532 == 0.01
//     3.57 == 0.05
//     214 == 10.00
func PriceRange(price float64) float64 {
	_, rng, _ := TickVal(price)
	return rng
}

// TickIndex returns the index between 1 and 350 for a valid price
//  ie 1.0104 == 1
//     1.0532 == 5
//     3.57 == 160
//     214 == 285
func TickIndex(price float64) int {
	_, _, idx := TickVal(price)
	return idx
}

// TickVal returns the rounded closest tick, what index the price is, and what range it's in
//  ie 1.0104 == (1.01, 0.01, 1)
//     1.0532 == (1.05, 0.01, 5)
//     3.57 == (3.55, 0.05, 160)
//     214 == (210, 10.00, 285)
func TickVal(price float64) (rnd, rng float64, idx int) {
	const floatRound = 0.0000005
	if price < 2 {
		rng = 0.01
		rnd = float64(int64(price*(1/rng)+0.5)) / (1 / rng)
		idx = int((rnd-1)/rng + 0 + floatRound)
	} else if price < 3 {
		rng = 0.02
		rnd = float64(int64(price*(1/rng)+0.5)) / (1 / rng)
		idx = int((rnd-2)/rng + 100 + floatRound)
	} else if price < 4 {
		rng = 0.05
		rnd = float64(int64(price*(1/rng)+0.5)) / (1 / rng)
		idx = int((rnd-3)/rng + 150 + floatRound)
	} else if price < 6 {
		rng = 0.10
		rnd = float64(int64(price*(1/rng)+0.5)) / (1 / rng)
		idx = int((rnd-4)/rng + 170 + floatRound)
	} else if price < 10 {
		rng = 0.20
		rnd = float64(int64(price*(1/rng)+0.5)) / (1 / rng)
		idx = int((rnd-6)/rng + 190 + floatRound)
	} else if price < 20 {
		rng = 0.50
		rnd = float64(int64(price*(1/rng)+0.5)) / (1 / rng)
		idx = int((rnd-10)/rng + 210 + floatRound)
	} else if price < 30 {
		rng = 1.00
		rnd = float64(int64(price*(1/rng)+0.5)) / (1 / rng)
		idx = int((rnd-20)/rng + 230 + floatRound)
	} else if price < 50 {
		rng = 2.00
		rnd = float64(int64(price*(1/rng)+0.5)) / (1 / rng)
		idx = int((rnd-30)/rng + 240 + floatRound)
	} else if price < 100 {
		rng = 5.00
		rnd = float64(int64(price*(1/rng)+0.5)) / (1 / rng)
		idx = int((rnd-50)/rng + 250 + floatRound)
	} else {
		rng = 10.00
		rnd = float64(int64(price*(1/rng)+0.5)) / (1 / rng)
		idx = int((rnd-100)/rng + 260 + floatRound)
	}

	return // rnd, rng, idx
}

// IndexTick returns the price from the index
// ie 1 == 1.01
//    5 == 1.05
func IndexTick(i int) float64 {
	if i < 100 {
		return 1 + float64(i-0)*0.01
	} else if i < 150 {
		return 2 + float64(i-100)*0.02
	} else if i < 170 {
		return 3 + float64(i-150)*0.05
	} else if i < 190 {
		return 4 + float64(i-170)*0.10
	} else if i < 210 {
		return 6 + float64(i-190)*0.20
	} else if i < 230 {
		return 10 + float64(i-210)*0.50
	} else if i < 240 {
		return 20 + float64(i-230)*1
	} else if i < 250 {
		return 30 + float64(i-240)*2
	} else if i < 260 {
		return 50 + float64(i-250)*5
	} else {
		return 100 + float64(i-260)*10
	}
}
