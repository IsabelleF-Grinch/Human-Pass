"use client";

import Header from "@/components/Header";
import styles from "./page.module.css";
import { useContract } from "@/hooks/useContract";

export default function Home() {
  const { userRole } = useContract();
  return (
    <div className={styles.page}>
      <Header />

      <main className={styles.main}>
        {userRole && (
          <>
            <p>
              Je suis {userRole} parce que j&apos;ai déployé les smart
              contracts.
            </p>
            <p>Bientôt j&apos;aurais accès à une page dédiée.</p>
          </>
        )}
      </main>
      <footer className={styles.footer}>Human Pass</footer>
    </div>
  );
}
