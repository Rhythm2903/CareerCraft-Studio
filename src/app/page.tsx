import Link from "next/link";
import { Button } from "@/components/ui/Button";

export default function HomePage() {
  return (
    <main className="mx-auto flex min-h-screen max-w-3xl flex-col items-center justify-center gap-6 px-6 text-center">
      <p className="text-sm font-medium uppercase tracking-wide text-indigo-700">
        Resume Builder
      </p>
      <h1 className="text-4xl font-bold text-slate-900">
        Pick a format. Answer a few questions. Get a resume.
      </h1>
      <p className="max-w-xl text-slate-600">
        Choose a resume format, fill in your details, edit the result right in the browser,
        and download it as a PDF or Word document.
      </p>
      <div className="flex gap-3">
        <Link href="/signup">
          <Button>Create an account</Button>
        </Link>
        <Link href="/login">
          <Button variant="secondary">Log in</Button>
        </Link>
      </div>
    </main>
  );
}
