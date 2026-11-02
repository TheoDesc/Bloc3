<?php

namespace App\Service;

use Symfony\Component\DependencyInjection\Attribute\Autowire;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\HttpFoundation\File\UploadedFile;

class FileUploader
{
    public function __construct(
        #[Autowire('%kernel.project_dir%/public/uploads')]
        private string $uploadDir,
        private Filesystem $filesystem,
    ) {
    }

    /** Enregistre le fichier dans public/uploads/YYYY-mm/ et retourne "YYYY-mm/nom.ext" */
    public function upload(UploadedFile $file): string
    {
        $folder = date('Y-m');
        $extension = $file->guessExtension() ?? 'jpg';
        $filename = bin2hex(random_bytes(16)) . '.' . $extension;

        $this->filesystem->mkdir($this->uploadDir . '/' . $folder);
        $file->move($this->uploadDir . '/' . $folder, $filename);

        return $folder . '/' . $filename;
    }

    /** Supprime le fichier (ignore les URL externes des fixtures) */
    public function remove(?string $photo): void
    {
        if (!$photo || str_starts_with($photo, 'http')) {
            return;
        }

        $this->filesystem->remove($this->uploadDir . '/' . $photo);
    }
}
