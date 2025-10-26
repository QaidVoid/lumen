# Lumen Analytics

A simple, lightweight analytics platform built with the Phoenix framework.

## Overview

Lumen Analytics is a straightforward analytics solution designed to help you track and analyze user behavior in your web applications. It leverages the power of the Phoenix framework to deliver fast, reliable, and easy-to-use analytics.

## Features

- Easy setup with Elixir and Phoenix
- Simple user interface for analytics data
- Scalable and lightweight
- Supports multiple database backends
- Open source and customizable

## Getting Started

### Prerequisites

Make sure you have the following installed on your machine:

- Elixir (latest version recommended)
- Phoenix framework
- PostgreSQL database running locally

### Development Environment Setup with Nix

This project includes a `flake.nix` tailored for NixOS, which sets up a development shell with all required dependencies, including Elixir 1.19, Phoenix tools, PostgreSQL, TailwindCSS, and helper scripts to manage your local Postgres server easily:

- `pg-setup`: creates the Postgres user
- `pg-start`: initializes and starts the Postgres server if not already running
- `pg-stop`: stops the Postgres server

You can either use `direnv` or `nix develop` to enter the development environment.
If you're not using the flake, you'd need to setup the development environment (including the database) manually.

### Installation

1. Clone the repository:
```sh
git clone https://github.com/QaidVoid/lumen-analytics.git
```

2. Install dependencies and set up the project:
```sh
cd lumen-analytics
mix deps.get
mix ecto.setup
```

3. Start the Phoenix server:
```sh
mix phx.server
```

4. Open your web browser and navigate to `http://localhost:4000` to access the Lumen Analytics dashboard.

## Usage

After starting the server, you can begin tracking analytics on your web app. The platform provides basic analytics metrics to help you understand user interactions and behavior.

## Mailbox

For local development, you can use the mailbox at `http://localhost:4000/dev/mailbox`.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License

This project is licensed under the MIT License.
