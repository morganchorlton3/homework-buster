# 🧠 Homework Buster

A mobile app + backend platform to help parents support their children’s homework — starting with weekly spellings.

## 📚 Overview

Homework Buster is a cross-platform learning companion designed for parents and children.
The first feature set focuses on weekly spelling tests:

Take a photo of the weekly spelling sheet

Use AI/OCR to extract spelling words automatically

Let children practise through fun, interactive modes

Give parents insight into progress, strengths, and weaknesses

Send reminders throughout the week to keep practice consistent

Future extensions will include reading, maths, handwriting and structured homework routines.

## 🚀 Tech Stack
Mobile App (Flutter)

Cross-platform for iOS & Android

Built with:

Flutter

Dart

Riverpod or Bloc

dio for networking

image_picker / camera for capturing spelling sheets

Local notifications for reminders

Backend API (FastAPI)

FastAPI for high-performance Python backend

PostgreSQL database

SQLModel / SQLAlchemy ORM

Pydantic for validation

JWT auth (or AWS Cognito/Auth0 later)

OCR via AWS Textract / Google Vision

Optional S3 for uploaded images