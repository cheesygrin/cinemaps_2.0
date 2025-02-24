-- Create movies table
CREATE TABLE IF NOT EXISTS public.movies (
    id TEXT PRIMARY KEY,
    title TEXT NOT NULL,
    overview TEXT NOT NULL,
    release_year INTEGER NOT NULL,
    rating FLOAT DEFAULT 0.0,
    poster_url TEXT,
    location_count INTEGER DEFAULT 0,
    tour_count INTEGER DEFAULT 0,
    location_progress FLOAT DEFAULT 0.0,
    is_in_watchlist BOOLEAN DEFAULT false,
    is_movie BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create movie_locations table
CREATE TABLE IF NOT EXISTS public.movie_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    movie_id TEXT REFERENCES public.movies(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    description TEXT NOT NULL,
    latitude FLOAT NOT NULL,
    longitude FLOAT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_movies_title ON public.movies(title);
CREATE INDEX IF NOT EXISTS idx_movie_locations_movie_id ON public.movie_locations(movie_id);

-- Enable RLS
ALTER TABLE public.movies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movie_locations ENABLE ROW LEVEL SECURITY;

-- Allow read access to everyone (including anonymous)
CREATE POLICY "Allow read access to everyone" ON public.movies
    FOR SELECT
    TO public
    USING (true);

CREATE POLICY "Allow read access to everyone" ON public.movie_locations
    FOR SELECT
    TO public
    USING (true);

-- Allow insert access to everyone (including anonymous)
CREATE POLICY "Allow insert access to everyone" ON public.movies
    FOR INSERT
    TO public
    WITH CHECK (true);

CREATE POLICY "Allow insert access to everyone" ON public.movie_locations
    FOR INSERT
    TO public
    WITH CHECK (true);

-- Allow update/delete for service_role only
CREATE POLICY "Allow update/delete for service_role" ON public.movies
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Allow update/delete for service_role" ON public.movie_locations
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- Create triggers for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_movies_updated_at
    BEFORE UPDATE ON public.movies
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_movie_locations_updated_at
    BEFORE UPDATE ON public.movie_locations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Create storage bucket for movie posters
INSERT INTO storage.buckets (id, name, public)
VALUES ('movie-posters', 'movie-posters', true);

-- Set up storage policies for movie-posters bucket
CREATE POLICY "Allow public read access"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'movie-posters');

CREATE POLICY "Allow authenticated uploads"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = 'movie-posters');

CREATE POLICY "Allow owners to update and delete"
ON storage.objects
FOR ALL
TO public
USING (bucket_id = 'movie-posters')
WITH CHECK (bucket_id = 'movie-posters'); 