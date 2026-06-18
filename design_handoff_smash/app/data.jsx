// data.jsx — Smash venue dataset (Sydney badminton courts)
const VENUES = [
  {
    id: "fivedock", name: "Five Dock Leisure Centre", suburb: "Five Dock", dedicated: false,
    address: "1A Wellbank St, Five Dock NSW 2046", from: 29, courts: 8, dist: 7.4, initial: "F",
    multisport: true, x: 0.30, y: 0.55,
    rates: [
      { label: "Off-peak", days: "Mon–Fri", time: "9:00 AM – 4:00 PM", price: 29, note: null },
      { label: "Peak", days: "Mon–Fri", time: "4:00 PM – 10:00 PM", price: 34, note: "Most popular" },
      { label: "Weekend", days: "Sat–Sun", time: "8:00 AM – 8:00 PM", price: 32, note: null },
    ],
    hours: [["Mon","6:00 AM – 10:00 PM"],["Tue","6:00 AM – 10:00 PM"],["Wed","6:00 AM – 10:00 PM"],["Thu","6:00 AM – 10:00 PM"],["Fri","6:00 AM – 10:00 PM"],["Sat","8:00 AM – 8:00 PM"],["Sun","8:00 AM – 6:00 PM"]],
  },
  {
    id: "concord", name: "Concord Oval Recreation Centre", suburb: "Concord", dedicated: false,
    address: "Loftus St, Concord NSW 2137", from: 29, courts: 8, dist: 10.0, initial: "C",
    multisport: true, x: 0.40, y: 0.47,
    rates: [
      { label: "Standard", days: "Mon–Fri", time: "9:00 AM – 5:00 PM", price: 29, note: null },
      { label: "Evening", days: "Mon–Fri", time: "5:00 PM – 10:00 PM", price: 35, note: null },
      { label: "Weekend", days: "Sat–Sun", time: "8:00 AM – 6:00 PM", price: 33, note: null },
    ],
    hours: [["Mon","6:30 AM – 10:00 PM"],["Tue","6:30 AM – 10:00 PM"],["Wed","6:30 AM – 10:00 PM"],["Thu","6:30 AM – 10:00 PM"],["Fri","6:30 AM – 10:00 PM"],["Sat","8:00 AM – 6:00 PM"],["Sun","Closed"]],
  },
  {
    id: "sop", name: "Sydney Olympic Park Sports Halls", suburb: "Sydney Olympic Park", dedicated: false,
    address: "Olympic Blvd, Sydney Olympic Park NSW 2127", from: 28, courts: 12, dist: 13.0, initial: "S",
    multisport: true, x: 0.46, y: 0.40,
    rates: [
      { label: "Day rate", days: "Mon–Fri", time: "7:00 AM – 5:00 PM", price: 28, note: "Best value" },
      { label: "Twilight", days: "Mon–Fri", time: "5:00 PM – 11:00 PM", price: 36, note: null },
      { label: "Weekend", days: "Sat–Sun", time: "7:00 AM – 9:00 PM", price: 34, note: null },
    ],
    hours: [["Mon","6:00 AM – 11:00 PM"],["Tue","6:00 AM – 11:00 PM"],["Wed","6:00 AM – 11:00 PM"],["Thu","6:00 AM – 11:00 PM"],["Fri","6:00 AM – 11:00 PM"],["Sat","7:00 AM – 9:00 PM"],["Sun","7:00 AM – 9:00 PM"]],
  },
  {
    id: "pro1", name: "Pro1 Badminton Centre", suburb: "Bankstown", dedicated: true,
    address: "23 Birch St, Bankstown NSW 2200", from: 29, courts: 14, dist: 19.4, initial: "P",
    multisport: false, x: 0.34, y: 0.70,
    rates: [
      { label: "Member", days: "Mon–Sun", time: "All day", price: 29, note: "Membership required" },
      { label: "Casual peak", days: "Mon–Fri", time: "5:00 PM – 11:00 PM", price: 38, note: null },
      { label: "Casual off-peak", days: "Mon–Fri", time: "9:00 AM – 5:00 PM", price: 32, note: null },
    ],
    hours: [["Mon","9:00 AM – 11:00 PM"],["Tue","9:00 AM – 11:00 PM"],["Wed","9:00 AM – 11:00 PM"],["Thu","9:00 AM – 11:00 PM"],["Fri","9:00 AM – 12:00 AM"],["Sat","8:00 AM – 12:00 AM"],["Sun","8:00 AM – 10:00 PM"]],
  },
  {
    id: "tbc", name: "The Badminton Club — Wetherill Park", suburb: "Wetherill Park", dedicated: true,
    address: "1273 The Horsley Dr, Wetherill Park NSW 2164", from: 29, courts: 7, dist: 28.5, initial: "B",
    multisport: false, x: 0.16, y: 0.62,
    rates: [
      { label: "Off-peak", days: "Mon–Fri", time: "10:00 AM – 4:00 PM", price: 29, note: null },
      { label: "Peak", days: "Mon–Fri", time: "4:00 PM – 11:00 PM", price: 40, note: "High demand" },
      { label: "Weekend", days: "Sat–Sun", time: "8:00 AM – 10:00 PM", price: 36, note: null },
    ],
    hours: [["Mon","10:00 AM – 11:00 PM"],["Tue","10:00 AM – 11:00 PM"],["Wed","10:00 AM – 11:00 PM"],["Thu","10:00 AM – 11:00 PM"],["Fri","10:00 AM – 11:00 PM"],["Sat","8:00 AM – 10:00 PM"],["Sun","8:00 AM – 10:00 PM"]],
  },
  {
    id: "kings", name: "Sydney Sports Club — Kings Park", suburb: "Kings Park", dedicated: false,
    address: "7 Hick St, Kings Park NSW 2148", from: 21, courts: 4, dist: 30.7, initial: "K",
    multisport: true, x: 0.20, y: 0.34,
    rates: [
      { label: "Standard", days: "Mon–Sun", time: "9:00 AM – 9:00 PM", price: 21, note: "Cheapest in Sydney" },
      { label: "Evening", days: "Mon–Fri", time: "6:00 PM – 10:00 PM", price: 26, note: null },
    ],
    hours: [["Mon","9:00 AM – 10:00 PM"],["Tue","9:00 AM – 10:00 PM"],["Wed","9:00 AM – 10:00 PM"],["Thu","9:00 AM – 10:00 PM"],["Fri","9:00 AM – 10:00 PM"],["Sat","8:00 AM – 8:00 PM"],["Sun","8:00 AM – 8:00 PM"]],
  },
];

Object.assign(window, { VENUES });
