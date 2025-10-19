<!-- Improved compatibility of back to top link: See: https://github.com/dhmnr/skipr/pull/73 -->
<a id="readme-top"></a>

<!-- *** Thanks for checking out the Best-README-Template. If you have a suggestion *** that would make this better, please fork the repo and create a pull request *** or simply open an issue with the tag "enhancement". *** Don't forget to give the project a star! *** Thanks again! Now go create something AMAZING! :D -->

<!-- PROJECT SHIELDS -->
<!-- *** I'm using markdown "reference style" links for readability. *** Reference links are enclosed in brackets [ ] instead of parentheses ( ). *** See the bottom of this document for the declaration of the reference variables *** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use. *** https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
<!-- [![LinkedIn][linkedin-shield]][linkedin-url] -->

<!-- PROJECT LOGO -->
<br />
<div align="center">
  <h3 align="center">🚢 Port Management System - ADVANCED DATABASE PROJECT ⭐</h3>

  <p align="center">
    <strong>🎯 PORTFOLIO SHOWCASE:</strong> Advanced Database-Driven Maritime Logistics Platform built with Django and MySQL, featuring advanced database design, complex pathfinding algorithms, and comprehensive maritime logistics management capabilities.
    <br/>
    <em>Last Updated: 2025-01-19 | Advanced Database & SQL Project</em>
    <br />
    <a href="https://github.com/virtual457/Port-Management-System"><strong>Explore the docs »</strong></a>
    <br />
    <br />
    <a href="https://github.com/virtual457/Port-Management-System">View Demo</a>
    ·
    <a href="https://github.com/virtual457/Port-Management-System/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    ·
    <a href="https://github.com/virtual457/Port-Management-System/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      <ul>
        <li><a href="#built-with">Built With</a></li>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#prerequisites">Prerequisites</a></li>
        <li><a href="#installation">Installation</a></li>
      </ul>
    </li>
    <li><a href="#usage">Usage</a></li>
    <li><a href="#roadmap">Roadmap</a></li>
    <li><a href="#contributing">Contributing</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About The Project

This project was **corely created to work on database skills** and demonstrates advanced SQL implementation including **pathfinding algorithms like Dijkstra's implemented in SQL** to get better at database management. The system manages complex maritime logistics operations with multi-role user management, real-time route optimization, and sophisticated booking systems.

### Key Features

- **Multi-Role User Management** (Admin, Shipowner, Customer, Manager, Staff)
- **Advanced Route Finding Algorithms** (Direct & Connected Routes)
- **Real-Time Berth Availability Management**
- **Complex Booking Systems** (Direct & Multi-Segment Connected Bookings)
- **Comprehensive Reporting & Analytics**
- **Spatial Data Management** (Port Locations with GPS Coordinates)
- **Transaction Management & Data Integrity**

### Database Architecture

The system implements sophisticated database design patterns including:

- **Normalized Schema Design** with proper foreign key relationships
- **Stored Procedures & Functions** for complex business logic
- **Triggers** for automatic data consistency
- **Common Table Expressions (CTEs)** for complex queries
- **Spatial Indexing** for geographical data
- **Transaction Management** for data integrity

### Advanced SQL Implementation

The system implements **Dijkstra-like pathfinding algorithms** using SQL to find optimal shipping routes:

#### Pathfinding Algorithms in SQL
1. **Direct Route Finding** - Finds direct routes between ports with capacity constraints
2. **Connected Route Finding (Multi-Segment)** - Implements graph traversal to find connected routes
3. **Route Optimization with CTEs** - Uses Common Table Expressions for complex route calculations

#### Complex Business Logic in Stored Procedures
- **Berth Availability Management** - Real-time berth availability checking with conflict detection
- **Connected Booking Management** - Multi-segment booking with transaction management
- **Advanced Query Patterns** - Recursive CTEs, Window Functions, and Spatial Queries

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Built With

* [Django 4.2+](https://www.djangoproject.com/)
* [MySQL 8.0+](https://www.mysql.com/)
* [Python 3.8+](https://www.python.org/downloads/)
* [Django ORM](https://docs.djangoproject.com/en/stable/topics/db/)
* [Advanced SQL](https://www.w3schools.com/sql/)
* [Spatial Data Types](https://dev.mysql.com/doc/refman/8.0/en/spatial-types.html)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- GETTING STARTED -->
## Getting Started

This is an example of how you may give instructions on setting up your project locally.
To get a local copy up and running follow these simple example steps.

### Prerequisites

This is an example of how to list things you need to use the software and how to install them.
* Python 3.8+
* MySQL 8.0+
* Django 4.2+
* Virtual Environment (recommended)

### Installation

1. Clone the repo
   ```sh
   git clone https://github.com/virtual457/port-management-system.git
   ```
2. Navigate to the project directory
   ```sh
   cd port-management-system
   ```
3. Set Up Virtual Environment
   ```sh
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```
4. Install Dependencies
   ```sh
   pip install django mysqlclient
   ```
5. Database Setup
   ```sh
   # Create MySQL database
   mysql -u root -p
   CREATE DATABASE port;
   USE port;
   
   # Import the complete database schema
   mysql -u root -p port < port_system/Create-Database.sql
   ```
6. Configure Django Settings
   Update database settings in `port_system/port_system/settings.py`
7. Run Migrations
   ```sh
   cd port_system
   python manage.py migrate
   ```
8. Start Development Server
   ```sh
   python manage.py runserver
   ```

Visit `http://127.0.0.1:8000/` to access the application.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- USAGE EXAMPLES -->
## Usage

### User Roles & Features

#### 🔧 Admin
- **User Management**: Create, edit, delete users with role assignments
- **Port Management**: Add, edit, delete ports with spatial coordinates
- **Berth Management**: Manage berth assignments and availability
- **System Analytics**: Comprehensive reporting and dashboard
- **Database Administration**: Full system oversight

#### 🚢 Shipowner
- **Fleet Management**: Manage ships, routes, and schedules
- **Route Optimization**: Advanced pathfinding for optimal routes
- **Berth Scheduling**: Real-time berth availability and booking
- **Revenue Analytics**: Detailed financial reporting
- **Schedule Management**: Complex voyage planning

#### 📦 Customer
- **Cargo Management**: Create and manage cargo shipments
- **Route Search**: Find optimal shipping routes (direct & connected)
- **Booking System**: Book cargo on available schedules
- **Tracking**: Real-time shipment tracking
- **Support**: Customer service integration

#### 👨‍💼 Manager/Staff
- **Operational Oversight**: Monitor port operations
- **Berth Coordination**: Manage berth assignments
- **Schedule Monitoring**: Track vessel movements
- **Reporting**: Generate operational reports

### Database Skills Demonstrated

1. **Advanced SQL Techniques**
   - **Stored Procedures**: 50+ complex business logic procedures
   - **Functions**: Custom SQL functions for data manipulation
   - **Triggers**: Automatic data consistency maintenance
   - **Views**: Complex data aggregation and reporting
   - **Indexes**: Performance optimization with strategic indexing

2. **Pathfinding Algorithms**
   - **Dijkstra-like Implementation**: Route optimization in SQL
   - **Graph Traversal**: Multi-segment route finding
   - **Constraint Satisfaction**: Capacity and time-based routing
   - **Cost Optimization**: Minimum cost path calculation

3. **Data Integrity & Transactions**
   - **ACID Compliance**: Full transaction support
   - **Referential Integrity**: Comprehensive foreign key constraints
   - **Data Validation**: Extensive check constraints
   - **Error Handling**: Robust exception management

_For more examples, please refer to the [Documentation](https://github.com/virtual457/Port-Management-System)_

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ROADMAP -->
## Roadmap

- [ ] Enhanced spatial data visualization
- [ ] Real-time vessel tracking integration
- [ ] Advanced analytics dashboard
- [ ] Mobile application development
- [ ] API development for third-party integration
- [ ] Machine learning for route optimization
- [ ] Blockchain integration for cargo tracking
- [ ] IoT sensor integration for port monitoring

See the [open issues](https://github.com/virtual457/Port-Management-System/issues) for a full list of proposed features (and known issues).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

This project demonstrates advanced database skills and is open for educational purposes. To contribute:

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Contribution Guidelines
- Add comprehensive SQL documentation
- Implement advanced database features
- Optimize query performance
- Add comprehensive testing

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- LICENSE -->
## License

This project is for educational and demonstration purposes, showcasing advanced database management and SQL implementation skills.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- CONTACT -->
## Contact

Chandan Gowda K S - chandan.keelara@gmail.com

Project Link: [https://github.com/virtual457/Port-Management-System](https://github.com/virtual457/Port-Management-System)

Project Link: [https://github.com/virtual457/Port-Management-System](https://github.com/virtual457/Port-Management-System)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- ACKNOWLEDGMENTS -->
## Acknowledgments

* [Django Community](https://www.djangoproject.com/) for the excellent web framework
* [MySQL Team](https://www.mysql.com/) for the powerful database management system
* [Choose an Open Source License](https://choosealicense.com)
* [GitHub Emojis](https://gist.github.com/rxaviers/7360908)
* [Malven's Flexbox Cheatsheet](https://flexbox.malven.co/)
* [Malven's Grid Cheatsheet](https://grid.malven.co/)
* [Img Shields](https://shields.io)
* [GitHub Pages](https://pages.github.com)
* [Font Awesome](https://fontawesome.com)
* [React Icons](https://react-icons.github.io/react-icons/search.html?q=search)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/virtual457/Port-Management-System.svg?style=for-the-badge
[forks-shield]: https://img.shields.io/github/forks/virtual457/Port-Management-System.svg?style=for-the-badge
[stars-shield]: https://img.shields.io/github/stars/virtual457/Port-Management-System.svg?style=for-the-badge
[issues-shield]: https://img.shields.io/github/issues/virtual457/Port-Management-System.svg?style=for-the-badge
[license-shield]: https://img.shields.io/github/license/virtual457/Port-Management-System.svg?style=for-the-badge
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=for-the-badge&logo=linkedin&colorB=555
[contributors-url]: https://github.com/virtual457/Port-Management-System/graphs/contributors
[forks-url]: https://github.com/virtual457/Port-Management-System/network/members
[stars-url]: https://github.com/virtual457/Port-Management-System/stargazers
[issues-url]: https://github.com/virtual457/Port-Management-System/issues
[license-url]: https://github.com/virtual457/Port-Management-System/blob/master/LICENSE.txt
[linkedin-url]: https://www.linkedin.com/in/chandan-gowda-k-s-765194186/
