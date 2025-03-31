# 🎬 usePopcorn

A sleek, single-page movie-rating app built with **React**, powered by an external movie API. Users can search for movies, rate them, and track their watched list—all with data persisting across sessions via **local storage**.

![image](https://github.com/user-attachments/assets/f6ed050e-9d3a-42cf-8ad3-48c406272c62)

![image](https://github.com/user-attachments/assets/9c653c17-330d-46ed-b050-387e7cee6a1b)


---

## 🚀 Features

- 🔍 **Search Movies**: Search for any movie by name and fetch results from the external movie API.
- ⭐ **Rate & Review**: Choose a movie from the search results and rate it yourself.
- 🧠 **Persistent Watchlist**: Watched movies and your ratings are stored in the browser (localStorage) and won't disappear after refresh.
- 📊 **Stats Tracking**:
  - Number of movies watched
  - Your average rating
  - IMDb average rating
  - Total watch time (in minutes)

---

## 🛠️ Tech Stack

- **React**
  - `useState`, `useEffect`, `useRef` hooks
- **Custom Components** and clean **component architecture**
- **Local Storage API** for data persistence
- **CSS Styling**: Tailored UI styling with custom styles
- **API Integration**: Fetches movie data from a public movie API

---

## 🧠 Learnings & Highlights

This project helped reinforce:
- Handling side effects and cleanup using `useEffect`
- Controlled components and local state management with `useState`
- Referencing DOM nodes and maintaining mutable values using `useRef`
- Using browser APIs like `localStorage`
- API integration and JSON parsing
- Clean and modular component-based architecture in React


---

## 📦 Getting Started

Clone the repo and install dependencies:

```bash
git clone https://github.com/your-username/usePopcorn.git
cd usePopcorn
npm install
npm run dev
