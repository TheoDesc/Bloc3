<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

final class Version20261102090000 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Création de la table des événements LAN.';
    }

    public function up(Schema $schema): void
    {
        $this->addSql('CREATE TABLE lan (
            id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
            nom VARCHAR(180) NOT NULL,
            description CLOB NOT NULL,
            ville VARCHAR(120) NOT NULL,
            adresse VARCHAR(255) DEFAULT NULL,
            date_debut DATETIME NOT NULL,
            date_fin DATETIME NOT NULL,
            jeu VARCHAR(120) NOT NULL,
            places_max INTEGER NOT NULL,
            prix DOUBLE PRECISION NOT NULL,
            image VARCHAR(500) DEFAULT NULL
        )');
    }

    public function down(Schema $schema): void
    {
        $this->addSql('DROP TABLE lan');
    }
}
