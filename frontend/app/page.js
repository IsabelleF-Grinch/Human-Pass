"use client";

import Header from "@/components/Header";
import styles from "./page.module.css";
import { useContract } from "@/hooks/useContract";

export default function Home() {
  const { userRole, isTxConfirming, isTxConfirmed, createClone } =
    useContract();

  const handleClick = () => {
    createClone();
  };

  return (
    <div className={styles.page}>
      <Header />

      <main className={styles.main}>
        {userRole == "admin" && (
          <>
            <p>
              Je suis {userRole} parce que j&apos;ai déployé les smart
              contracts.
            </p>
            <p>Bientôt j&apos;aurais accès à une page dédiée.</p>
          </>
        )}
        {userRole == undefined && (
          <>
            {!isTxConfirmed && (
              <>
                <h2>Demander une certification</h2>
                <button onClick={handleClick}>Obtenir</button>
              </>
            )}
            {isTxConfirmed && <p>mainteant il faut mint</p>}
            {isTxConfirming && <p>...isCloning</p>}
          </>
        )}
      </main>
      <footer className={styles.footer}>Human Pass</footer>
    </div>
  );
}
