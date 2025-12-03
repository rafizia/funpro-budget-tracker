# Realtime Q&A Platform

## Deskripsi Proyek

**Realtime Q&A** adalah platform interaktif berbasis web yang memungkinkan audiens berpartisipasi secara langsung selama acara, kuliah, atau rapat dengan mengajukan sebuah pertanyaan.

## Fitur Utama

1. **Instant Real-time Updates**: Saat pengguna mengirim pertanyaan, pengguna lain dapat melihatnya seketika tanpa perlu *refresh*.

2. **Secure Authentication (OAuth 2.0)**: Sistem login terintegrasi dengan **Google Sign-In**, memastikan keamanan akses pengguna.

3. **QR Code Room Access**: Aplikasi secara otomatis men-generate **QR Code** unik untuk setiap *room*. Peserta cukup memindai kode tersebut menggunakan kamera HP untuk langsung bergabung ke sesi tanya jawab.

## User Flow

1. **Login**: Pengguna dapat login menggunakan Google Sign-In untuk dapat mengakses platform.

2. **Create Room**: Setelah login, pengguna dapat membuat *room* baru dengan memberikan nama *room*.

3. **Join Room**: Pengguna lain dapat bergabung ke *room* yang sama dengan memindai QR Code yang dihasilkan tanpa perlu login.

4. **Ask Question**: Setelah bergabung ke *room*, pengguna dapat mengajukan pertanyaan.

5. **Real-time Updates**: Setiap pertanyaan yang diajukan akan terlihat secara real-time oleh pengguna lain yang terhubung ke *room* yang sama.

## Tech Stack

### Core & Backend
* **[Elixir](https://elixir-lang.org/)**
* **[Phoenix Framework](https://www.phoenixframework.org/)**
* **[PostgreSQL](https://www.postgresql.org/)**

### Frontend & Realtime
* **Phoenix LiveView**
* **Tailwind CSS**

### Dependencies
* `ueberauth_google`: Menangani flow autentikasi OAuth 2.0.
* `eqrcode`: Generator QR Code berbasis SVG.
* `ecto_sql`: Wrapper database dan query generator.

## Installation & Setup

### Prerequisites
* Elixir (v1.14 atau lebih baru) & Erlang.
* PostgreSQL Database Server.
* Git.

### Langkah Instalasi

1.  **Clone Repositori**
    ```bash
    git clone <repository-url>
    cd realtime_qa
    ```

2.  **Install Dependensi**
    ```bash
    mix deps.get
    ```

3.  **Konfigurasi Environment Variables:**
    Aplikasi ini membutuhkan kredensial Google OAuth agar fitur login berfungsi.

    **Untuk Windows (PowerShell):**
    ```powershell
    $env:GOOGLE_CLIENT_ID="MASUKKAN_CLIENT_ID_ANDA_DISINI"
    $env:GOOGLE_CLIENT_SECRET="MASUKKAN_CLIENT_SECRET_ANDA_DISINI"
    $env:GOOGLE_REDIRECT_URI="http://localhost:4000/auth/google/callback"
    ```

    **Untuk Linux/Mac (Bash/Zsh):**
    ```bash
    export GOOGLE_CLIENT_ID="MASUKKAN_CLIENT_ID_ANDA_DISINI"
    export GOOGLE_CLIENT_SECRET="MASUKKAN_CLIENT_SECRET_ANDA_DISINI"
    export GOOGLE_REDIRECT_URI="http://localhost:4000/auth/google/callback"
    ```
    
    > *Catatan: Pastikan Anda telah mendaftarkan aplikasi di Google Cloud Console dan mengaktifkan callback URL yang sesuai.*

4.  **Setup Database**
    ```bash
    mix ecto.setup
    ```

5.  **Jalankan Server**
    ```bash
    mix phx.server
    ```

6.  **Akses Aplikasi**
    Buka browser dan kunjungi:
    [http://localhost:4000](http://localhost:4000)

## Lesson Learned

### 1. Immutability

Di Elixir, semua struktur data bersifat immutable. Artinya, Elixir tidak pernah memodifikasi data yang ada di memori, sebaliknya Elixir selalu membuat versi baru dari data tersebut.

Contoh:
```elixir
def create_question(attrs \\ %{}) do
    %Question{}
    |> Question.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, question} ->
        RealtimeQaWeb.Endpoint.broadcast("room:#{question.room_id}", "question_created", %{
          question: question
        })

        {:ok, question}

      {:error, changeset} ->
        {:error, changeset}
    end
end
```

1. `%Question{}`: Membuat sebuah struct Question baru yang kosong.

2. `|> Question.changeset(attrs)`: Data `%Question{}` dikirim ke fungsi changeset.
Fungsi ini tidak mengubah struct kosong tadi. Sebaliknya, fungsi tersebut menghasilkan dan mengembalikan struktur data baru (sebuah Ecto.Changeset) yang berisi informasi tentang perubahan yang ingin dilakukan.

### 2. Pattern Matching

Pattern matching memungkinkan kita untuk memeriksa struktur data dan mengekstrak nilai atau menentukan alur logika berdasarkan bentuk datanya.

Contoh:
```elixir
def add_upvote(question_id, user_fingerprint) do
    case Repo.transaction(fn ->
           case insert_upvote_record(question_id, user_fingerprint) do
             {:ok, _upvote} ->
               increment_upvote_count(question_id)

             {:error, changeset} ->
               Repo.rollback(changeset)
        end
    end)
end
```

1. `case insert_upvote_record(question_id, user_fingerprint) do`: Kode ini memanggil fungsi `insert_upvote_record` dan mencocokkan hasil kembaliannya dengan pola-pola yang didefinisikan di bawahnya.

2. `{:ok, _upvote}`: Jika insert berhasil, maka akan dijalankan `increment_upvote_count(question_id)`.

3. `{:error, changeset}`: Jika insert gagal, maka akan dijalankan `Repo.rollback(changeset)`.

### 3. Higher-Order Function

Higher-order function adalah fungsi yang menerima fungsi lain sebagai argumen atau mengembalikan fungsi lain sebagai output.

```elixir
defp broadcast_prioritize_change(room_id) do
    fn updated_question ->
      RealtimeQaWeb.Endpoint.broadcast("room:#{room_id}", "question_prioritized", %{
        question: updated_question
      })
      {:ok, updated_question}
    end
end
```
1. Fungsi ini mengambalikan sebuah fungsi yang menerima `updated_question` sebagai parameter
2. Fungsi ini melakukan broadcast menggunakan `room_id`, lalu mengembalikan `{:ok, updated_question}`

### 4. Function Compostion


### 5. Pure Function

Pure Function adalah fungsi yang selalu menghasilkan output yang sama untuk input yang sama. Fungsi ini tidak memiliki efek sampang (tidak mengubah state di luar fungsi, tidak tulis database, tidak broadcast, dll)

```elixir
defp extract_name_from_email(email) do
  email
  |> String.split("@")
  |> List.first()
  |> String.split(".")
  |> Enum.map(&String.capitalize/1)
  |> Enum.join(" ")
end
```

1. Fungsi ini mengambil nama dari sebuah email
2. Untuk input yang sama ("hilmy@gmail.com") selalu menghasilkan output yang sama juga ("hilmy")