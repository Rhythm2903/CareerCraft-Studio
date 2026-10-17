import Link from "next/link";
import { LoginForm } from "@/features/auth/components/LoginForm";

export default function LoginPage() {
  return (
    <main className="mx-auto flex min-h-screen max-w-sm flex-col justify-center gap-6 px-6">
      <div>
        <h1 className="text-2xl font-bold text-slate-900">Log in</h1>
        <p className="mt-1 text-sm text-slate-600">
          New here?{" "}
          <Link href="/signup" className="font-medium text-indigo-700 hover:underline">
            Create an account
          </Link>
        </p>
      </div>
      <LoginForm />
    </main>
  );
}
