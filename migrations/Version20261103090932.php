<?php

declare(strict_types=1);

namespace DoctrineMigrations;

use Doctrine\DBAL\Schema\Schema;
use Doctrine\Migrations\AbstractMigration;

final class Version20261103090932 extends AbstractMigration
{
    public function getDescription(): string
    {
        return 'Ajout des coordonnées et des informations de contact aux LAN';
    }

    public function up(Schema $schema): void
    {
        $this->addSql('ALTER TABLE lan ADD COLUMN latitude DOUBLE PRECISION DEFAULT NULL');
        $this->addSql('ALTER TABLE lan ADD COLUMN longitude DOUBLE PRECISION DEFAULT NULL');
        $this->addSql('ALTER TABLE lan ADD COLUMN nom_contact VARCHAR(120) DEFAULT NULL');
        $this->addSql('ALTER TABLE lan ADD COLUMN email_contact VARCHAR(180) DEFAULT NULL');
    }

    public function down(Schema $schema): void
    {
        $this->addSql('ALTER TABLE lan DROP COLUMN latitude');
        $this->addSql('ALTER TABLE lan DROP COLUMN longitude');
        $this->addSql('ALTER TABLE lan DROP COLUMN nom_contact');
        $this->addSql('ALTER TABLE lan DROP COLUMN email_contact');
    }
}
