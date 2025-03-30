# Port Management System

A web-based application built with Django to manage port operations effectively. This project uses a SQLite database and supports basic port management functionalities.

## 🛠️ Prerequisites

Before setting up the project, make sure the following are installed on your system:

- Python 3.7 or higher
- pip (Python package installer)
- Virtualenv (optional but recommended)

## 🚀 Setup Instructions

Follow the steps below to set up and run the project:

### 1. Clone or Extract the Project

If downloaded as a ZIP file, extract it. You should see the following directory structure:

```
Port-Management-System-main/
└── port_system/
    ├── manage.py
    ├── db.sqlite3
    ├── core/
    └── ...
```

### 2. Create and Activate Virtual Environment (Optional but Recommended)

```bash
cd Port-Management-System-main/port_system
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

> **Note:** If `requirements.txt` is not available, manually install Django:
```bash
pip install django
```

### 4. Apply Migrations (If Needed)

The project includes a pre-configured SQLite database. If you'd prefer to start fresh:

```bash
python manage.py migrate
```

Or you can import the existing SQL schema:

```bash
# Optional: Run this only if you're not using the included `db.sqlite3`
sqlite3 db.sqlite3 < Create-Database.sql
```

### 5. Run the Development Server

```bash
python manage.py runserver
```

Visit `http://127.0.0.1:8000/` in your web browser to use the application.

### 6. Create Superuser (Optional)

To access the Django admin panel:

```bash
python manage.py createsuperuser
```

Then go to `http://127.0.0.1:8000/admin/`

## 📁 Project Structure

- `core/` - Contains application logic
- `db.sqlite3` - Default database file
- `Create-Database.sql` - SQL script to create the database schema
- `manage.py` - Django management script

## 🧑‍💻 Developer Notes

- Developed using Django framework
- Make sure to keep your `SECRET_KEY` and other credentials secure in a production environment

## 🧾 License

This project is for educational/demo purposes. Contact the author if you'd like to use it in production.
