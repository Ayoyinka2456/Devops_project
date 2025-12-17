# End-to-End Containerized Java Application Deployment on Kubernetes

## 📌 Project Overview

This project demonstrates the design and implementation of a **production-ready Java web application deployment** using modern DevOps and cloud infrastructure best practices. The solution showcases **containerization, Kubernetes orchestration, infrastructure automation, and CI/CD workflows** on AWS, closely reflecting real-world enterprise infrastructure environments.

The primary goal of this project is to automate the full lifecycle of a Java application—from build and containerization to scalable deployment on a highly available Kubernetes cluster.

---

## 🎯 Project Objectives

* Containerize a Java web application using a **multi-stage Dockerfile**
* Deploy the application on **Apache Tomcat**
* Provision cloud infrastructure using **Infrastructure as Code (IaC)**
* Automate Kubernetes cluster creation and management
* Deploy a **highly available application** across multiple availability zones
* Implement CI/CD-ready workflows aligned with industry best practices

---

## 🏗️ High-Level Architecture

* **AWS Cloud Infrastructure** (VPC, Subnets, EC2)
* **Terraform** for infrastructure provisioning
* **Ansible** for configuration management and Kubernetes automation
* **Docker** for application containerization
* **Kubernetes** for container orchestration
* **LoadBalancer Service** for external application access

---

## ⚙️ Key Features

* Multi-stage Docker build for optimized Java application images
* Automated AWS infrastructure provisioning using Terraform
* Reusable and idempotent Ansible playbooks
* Kubernetes deployment with multiple replicas for high availability
* External access via Kubernetes Service (LoadBalancer)
* Clean separation between infrastructure, configuration, and application layers

---

## 📂 Repository Structure (Simplified)

```
├── terraform/           # AWS infrastructure provisioning (VPC, EC2, networking)
├── ansible/             # Playbooks for configuration and Kubernetes automation
├── docker/              # Dockerfile for Java application
├── kubernetes/          # Deployment and Service manifests
├── scripts/             # Helper scripts for automation
└── README.md
```

---

## 🚀 How to View the Complete Solution

The **full implementation and working solution** for this project is available in the following GitHub branch:

👉 **Branch Name:** `project-3`

Please switch to this branch to review:

* Terraform IaC files
* Ansible playbooks
* Dockerfile
* Kubernetes manifests
* Supporting scripts and configurations

---

## ✅ Validation

* The Docker image builds successfully and runs on Apache Tomcat
* Kubernetes workloads deploy with **two replicas** across worker nodes
* The application is accessible externally using the **Load Balancer DNS endpoint**

---

## 🧠 Skills Demonstrated

* Cloud Infrastructure Engineering (AWS)
* Containerization & Orchestration
* Infrastructure Automation
* Configuration Management
* High Availability Design
* DevOps & CI/CD Concepts

---

## 🔗 Source Application

The Java application used in this project is sourced from:
[https://github.com/ravi2krishna/proj-mdp-152-155.git](https://github.com/ravi2krishna/proj-mdp-152-155.git)

---

## 📎 Notes

This project was built as a hands-on demonstration of **enterprise-style infrastructure engineering and DevOps workflows**, suitable for entry-level to early-career cloud and infrastructure engineering roles.



=====================================

Deploying a simple Java project on a Tomcat server using a separate Build (Maven) server and Tomcat server.

Source code: Github Repo (branch: project-1)
git branch: 'project-1', url: 'https://github.com/Ayoyinka2456/Devops_project.git'

Syntax to check deployment: <public-ip of tomcat>:8080/<name of java-app>
example:http://3.139.61.97:8080/WebAppCal-1.3.5/

JAVA_HOME path: /usr/lib/jvm/jre-openjdk
To confirm $JAVA_HOME

Maven path: /opt/maven/bin/mvn
